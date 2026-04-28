class AppConstants {
  // base
  static const String BASE_URL = 'https://gk-app-production-45a2.up.railway.app';

  // login
  static const String LOGIN = '/api/v1/user/login';
  static const String SIGNUP = '/api/v1/user/add';
  static const String USERPROFILE = '/api/v1/user/profile';

  // Users
  static const String GETUSERS = '/api/v1/user/all';

  // customer
  static const String CUSTOMER = '/api/v1/customer';
  static const String CUSTOMERByUNIQUE = '/api/v1/customer/by-unique';

  // vendor
  static const String VENDORByUNIQUE = '/api/v1/vendor/by-unique';
  static const String VENDOR = '/api/v1/vendor';
  static const String VENDOREMPLOYEE = '/api/v1/vendor-employee';
  static const String VENDOREMPLOYEECATEGORY = '/api/v1/vendor-employee/category';

  // employee (Internal Staff)
  static const String Employee = '/api/v1/customer/employee';
  static const String EmployeeCategory = '/api/v1/customer/employee/category';

  // customer contact (Hospital Side)
  static const String CUSTOMER_CONTACT = '/api/v1/customer-contact';
  static const String CONTACT_POSITION = '/api/v1/customer-contact/position';

  // wallet
  static const String GETWALLET = '/api/v1/expenses/get-wallet';
  static const String TRANSCATIONS = '/api/v1/expenses/transactions';
  static const String EXPENSESCATEGORY = '/api/v1/expenses/category';
  static const String FUNDSWITHDRAW = '/api/v1/expenses/withdraw-funds';
  static const String GETCUSTOMEROUTSTANDING = '/api/v1/customer/payment/customer';
  static const String AllOUTSTANDING = '/api/v1/customer/payment';

  // product
  static const String GETPRODUCT = '/api/v1/product/product';
  static const String CATEGORYPRODUCT = '/api/v1/product/category';
  static const String ADDPRODUCT = '/api/v1/customer/product/add';
  static const String GETPRODUCTBYCUSTOMER = '/api/v1/customer/product/by-customer';
  static const String DELETEPRODUCT = "/api/v1/product/delete";
  static const String UPDATEPRODUCT = "/api/v1/product/update";

  // Manufacturer
  static const String GETMANUFACTURER = '/api/v1/product/manufacturer';
  static const String PRODUCTMANUFACTURER = '/api/v1/customer/product/manufacturer';

  // reports
  static const String INSTALLATIONREPORT = '/api/v1/installation-report';

  // leads
  static const String POSTLEADS = '/api/v1/lead';

  // Dashboard Stats
  static const String DASHBOARD_STATS = '/api/v1/stats/dashboard';
  
  // Import
  static const String EXCEL_IMPORT = '/api/v1/import/excel';
  static const String EXCEL_EXPORT = '/api/v1/export/customers';
  
  // Routes
  static const String routeCustomers = '/CustomersList';
  
  // Classification
  static const String CATEGORY = '/api/v1/category';
  
  // Location
  static const String LOCATION = '/api/v1/location';
}
