---
name: API Requests & TanStack Query
description: Standardizes frontend API architecture using Axios, TanStack Query (@tanstack/react-query), centralized API service modules, subject-based custom query/mutation hooks, strictly managed query key constants, and mandatory unit tests for every query/mutation hook.
---

# API Requests & TanStack Query Skill

This skill defines the mandatory workflow and architecture for managing HTTP requests, server state, data fetching, mutations, caching, and unit testing across frontend applications.

---

## 1. Dependency Verification & Initialization

Whenever working with API requests or adding data-fetching capabilities to a project:

### 1.1 Check Package Dependencies
1. Inspect `package.json` in the client application:
   - Verify if `@tanstack/react-query` (TanStack Query) is installed at the latest version.
   - Verify if `axios` is installed at the latest version.

### 1.2 Prompt the User if Dependencies are Missing
- **If `@tanstack/react-query` is not installed**:
  - Ask the user for confirmation to install `@tanstack/react-query` (and `@tanstack/react-query-devtools` if appropriate) using `pnpm add @tanstack/react-query`.
- **If `axios` is not installed**:
  - Ask the user for confirmation to install `axios` using `pnpm add axios`.

### 1.3 QueryClientProvider Setup
Ensure `QueryClientProvider` wraps the root application in `main.tsx` or `App.tsx`:
```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes default cache freshness
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

export function Root() {
  return (
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  );
}
```

---

## 2. API Layer Architecture (Axios Only)

All HTTP interactions must use **Axios** and reside in an `api/` directory (e.g. `src/services/api/` or `src/api/`).

### 2.1 Central Axios Client (`src/services/api/api.client.ts` or `src/api/client.ts`)
- Configured with `baseURL` (e.g. `/api` from constants).
- `withCredentials: true` for cookie management.
- Request Interceptor: Injects `Authorization: Bearer <token>` from secure storage.
- Response Interceptor:
  - Centralized error formatting.
  - Transparent 401 handling & silent token refresh retry logic.

### 2.2 Subject-Based API Services
Organize API functions by domain entity/subject:
- `src/services/api/users.api.ts`
- `src/services/api/system-categories.api.ts`
- `src/services/api/work-plans.api.ts`

Each module exports clean, typed async functions:
```ts
// Example: src/services/api/users.api.ts
import { apiClient } from './api.client';
import type { UserResponse, CreateUserInput, UpdateUserInput } from '../../types/user.types';

export const usersApi = {
  getMe: async (): Promise<UserResponse> => {
    const { data } = await apiClient.get<UserResponse>('/users/me');
    return data;
  },
  getAll: async (): Promise<UserResponse[]> => {
    const { data } = await apiClient.get<UserResponse[]>('/users');
    return data;
  },
  create: async (payload: CreateUserInput): Promise<UserResponse> => {
    const { data } = await apiClient.post<UserResponse>('/users', payload);
    return data;
  },
};
```

---

## 3. Query Key Management (Strict Constants)

**NEVER use magic strings or inline arrays for query keys.**
Every subject MUST have a query keys constant factory file located directly next to its hooks.

### 3.1 Key Factory Pattern (`src/hooks/<subject>/<subject>.keys.ts` or `<subject>-queries.constants.ts`)
```ts
// Example: src/hooks/users/user-queries.constants.ts
export const USER_QUERY_KEYS = {
  all: ['users'] as const,
  lists: () => [...USER_QUERY_KEYS.all, 'list'] as const,
  list: (filters?: Record<string, unknown>) =>
    [...USER_QUERY_KEYS.lists(), filters ?? {}] as const,
  details: () => [...USER_QUERY_KEYS.all, 'detail'] as const,
  detail: (id: string) => [...USER_QUERY_KEYS.details(), id] as const,
  me: () => [...USER_QUERY_KEYS.all, 'me'] as const,
} as const;
```

---

## 4. Custom Hooks Layer (Subject-Based)

All API calls must be wrapped and consumed through custom hooks organized by subject in `src/hooks/<subject>/`:

### 4.1 Directory Structure
```
src/hooks/
├── users/
│   ├── user-queries.constants.ts    # Query keys factory
│   ├── useUsersQuery.ts             # Fetch all users
│   ├── useUserDetailQuery.ts        # Fetch single user
│   ├── useCreateUserMutation.ts     # Create user mutation + invalidation
│   ├── useUpdateUserMutation.ts     # Update user mutation + invalidation
│   ├── useDeleteUserMutation.ts     # Delete user mutation + invalidation
│   └── user-hooks.test.tsx          # Comprehensive unit tests for all user hooks
├── system-categories/
│   ├── system-category-queries.constants.ts
│   ├── useSystemCategoriesQuery.ts
│   ├── useCategoryOptionsQuery.ts
│   ├── useCreateCategoryMutation.ts
│   ├── useAddCategoryOptionMutation.ts
│   ├── useReorderOptionsMutation.ts
│   └── system-category-hooks.test.tsx # Comprehensive unit tests for all category hooks
```

### 4.2 Query Hook Example
```ts
// src/hooks/users/useUsersQuery.ts
import { useQuery } from '@tanstack/react-query';
import { usersApi } from '../../services/api/users.api';
import { USER_QUERY_KEYS } from './user-queries.constants';
import type { UserResponse } from '../../types/user.types';

export function useUsersQuery(filters?: Record<string, unknown>) {
  return useQuery<UserResponse[], Error>({
    queryKey: USER_QUERY_KEYS.list(filters),
    queryFn: () => usersApi.getAll(),
  });
}
```

### 4.3 Mutation Hook Example (with Automatic Invalidation)
```ts
// src/hooks/users/useCreateUserMutation.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { usersApi } from '../../services/api/users.api';
import { USER_QUERY_KEYS } from './user-queries.constants';
import type { CreateUserInput, UserResponse } from '../../types/user.types';

export function useCreateUserMutation() {
  const queryClient = useQueryClient();

  return useMutation<UserResponse, Error, CreateUserInput>({
    mutationFn: (payload) => usersApi.create(payload),
    onSuccess: () => {
      // Invalidate queries to refresh data across all components automatically
      queryClient.invalidateQueries({ queryKey: USER_QUERY_KEYS.lists() });
    },
  });
}
```

---

## 5. Mandatory Unit Testing for Every Query & Mutation Hook

**EVERY query hook and mutation hook MUST have unit test coverage.** No hook should be created or modified without accompanying unit tests in `src/hooks/<subject>/[subject]-hooks.test.tsx` (or `[hookName].test.tsx`).

### 5.1 Test Wrapper Setup
Create a reusable query client wrapper for `renderHook`:
```tsx
import type { ReactNode } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

export function createQueryWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false, // Disable retries in tests for fast deterministic assertions
        gcTime: 0,
      },
      mutations: {
        retry: false,
      },
    },
  });

  return {
    queryClient,
    wrapper: ({ children }: { children: ReactNode }) => (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    ),
  };
}
```

### 5.2 Testing Query Hooks
Verify successful data retrieval, loading states, and error handling:
```tsx
// Example: Testing useUsersQuery
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { usersApi } from '../../services/api/users.api';
import { useUsersQuery } from './useUsersQuery';
import { createQueryWrapper } from '../../test/test-utils';

vi.mock('../../services/api/users.api');

describe('useUsersQuery', () => {
  it('fetches and returns users list successfully', async () => {
    const mockUsers = [{ id: '1', email: 'user@example.com', roles: [] }];
    vi.mocked(usersApi.getAll).mockResolvedValueOnce(mockUsers);

    const { wrapper } = createQueryWrapper();
    const { result } = renderHook(() => useUsersQuery(), { wrapper });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(mockUsers);
    expect(usersApi.getAll).toHaveBeenCalledTimes(1);
  });

  it('handles query error gracefully', async () => {
    vi.mocked(usersApi.getAll).mockRejectedValueOnce(new Error('Network error'));

    const { wrapper } = createQueryWrapper();
    const { result } = renderHook(() => useUsersQuery(), { wrapper });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe('Network error');
  });
});
```

### 5.3 Testing Mutation Hooks & Cache Invalidation
Verify mutation execution and query cache invalidation:
```tsx
// Example: Testing useCreateUserMutation
describe('useCreateUserMutation', () => {
  it('calls create user API and invalidates users list cache on success', async () => {
    const newUser = { id: '2', email: 'new@example.com', roles: [] };
    vi.mocked(usersApi.create).mockResolvedValueOnce(newUser);

    const { queryClient, wrapper } = createQueryWrapper();
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries');

    const { result } = renderHook(() => useCreateUserMutation(), { wrapper });

    result.current.mutate({
      email: 'new@example.com',
      password: 'password123',
      roles: [],
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(newUser);
    expect(invalidateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        queryKey: expect.arrayContaining(['users', 'list']),
      })
    );
  });
});
```

---

## 6. Consumption in React Components

Components must use the custom hooks directly for clean separation of concerns and reactivity:

```tsx
import { useUsersQuery } from '../../../hooks/users/useUsersQuery';
import { useCreateUserMutation } from '../../../hooks/users/useCreateUserMutation';
import { CustomTable } from '../../../components/common/CustomTable/CustomTable';

export const AdminUsersPage = () => {
  const { data: users, isLoading, error } = useUsersQuery();
  const { mutate: createUser, isPending: isCreating } = useCreateUserMutation();

  const handleCreate = (data: CreateUserInput) => {
    createUser(data, {
      onSuccess: () => {
        // Handle modal close or local notification
      },
    });
  };

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error.message} />;

  return <CustomTable data={users} ... />;
};
```

---

## 7. Summary Checklist for Agent Execution

1. **Verify Dependencies**: Check if `@tanstack/react-query` and `axios` are installed at latest version; ask user if not.
2. **Setup Provider**: Verify `QueryClientProvider` is configured in the root tree.
3. **Use Axios Client**: All endpoints must use `axios` inside `src/services/api/` or `src/api/`.
4. **Define Query Keys**: Create a constants file with key factory methods next to the hooks.
5. **Implement Custom Hooks**: Wrap queries and mutations in dedicated hooks under `src/hooks/<subject>/`.
6. **Automatic Invalidation**: Ensure mutations invalidate relevant query keys on success.
7. **MANDATORY Unit Tests for Every Query/Mutation**: Implement unit tests for all queries and mutations covering success, failure, and cache invalidation.
8. **Component Usage**: Consume only through the custom hooks, never calling raw API functions inside components.
