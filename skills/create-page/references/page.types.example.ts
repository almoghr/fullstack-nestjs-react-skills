export interface ExamplePageItem {
  id: string;
  name: string;
  status: ExampleStatus;
  createdAt: string;
  updatedAt: string;
}

export type ExampleStatus = 'active' | 'inactive' | 'pending';

export interface ExampleFilterState {
  searchTerm: string;
  limit: number;
}
