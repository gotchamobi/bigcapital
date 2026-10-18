/**
 * The path prefix the app is served under ('' at the root, '/g-bigcapital' when
 * built with PUBLIC_URL=/g-bigcapital/). Every absolute URL the app builds —
 * API calls, the socket, router history — has to start with it.
 */
export const BASE_PATH = import.meta.env.BASE_URL.replace(/\/$/, '');
