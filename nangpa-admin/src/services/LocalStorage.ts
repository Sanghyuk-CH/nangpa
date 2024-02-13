/* eslint-disable */
class LocalStorage {
  set token(_token: any) {
    if (_token) window.localStorage.setItem('nangpa-admin-web-token', JSON.stringify(_token));
    else window.localStorage.removeItem('nangpa-admin-web-token');
  }

  get token(): any {
    let token = window.localStorage.getItem('nangpa-admin-web-token');
    try {
      if (token != null) {
        token = JSON.parse(token);
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  private static instance: LocalStorage;

  private constructor() {}

  public static getInstance() {
    return this.instance || (this.instance = new this());
  }

  public clear() {
    this.token = null;
  }
}

export default LocalStorage.getInstance();
