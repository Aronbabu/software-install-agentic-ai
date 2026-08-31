const AUTH_KEY = "agentic_ai_portal_auth";

export const auth = {
  isAuthenticated(): boolean {
    return localStorage.getItem(AUTH_KEY) === "true";
  },

  signIn(): void {
    localStorage.setItem(AUTH_KEY, "true");
  },

  signOut(): void {
    localStorage.removeItem(AUTH_KEY);
  },
};