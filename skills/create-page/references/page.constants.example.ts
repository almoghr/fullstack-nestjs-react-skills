export const PAGE_ROUTES = {
  EXAMPLE: '/example',
  EXAMPLE_DETAILS: '/example/:id',
} as const;

export const DEFAULT_PAGE_LIMIT = 10;
export const DEFAULT_INITIAL_PAGE = 1;

export const PAGE_I18N_KEYS = {
  PAGE_TITLE: 'examplePage.title',
  PAGE_SUBTITLE: 'examplePage.subtitle',
  EMPTY_STATE: 'examplePage.emptyState',
  SEARCH_PLACEHOLDER: 'examplePage.searchPlaceholder',
  ACTIONS_SUBMIT: 'examplePage.actions.submit',
  ACTIONS_CANCEL: 'examplePage.actions.cancel',
} as const;
