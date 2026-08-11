// @ts-nocheck
export const FEATURE_MESSAGES = {
  NOT_FOUND: 'Item not found',
  CREATED_SUCCESSFULLY: 'Item created successfully',
  UPDATED_SUCCESSFULLY: 'Item updated successfully',
  DELETED_SUCCESSFULLY: 'Item deleted successfully',
} as const;

export const FEATURE_VALIDATION_MESSAGES = {
  NAME_REQUIRED: 'Name is required',
  NAME_MIN_LENGTH: 'Name must be at least 2 characters',
  INVALID_FORMAT: 'Invalid format provided',
} as const;

export const FEATURE_DEFAULTS = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 10,
} as const;
