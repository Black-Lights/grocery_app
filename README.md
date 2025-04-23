# **Grocery Management App** 🛒  

A **Flutter** application for managing household groceries with **storage tracking, shopping lists, expiry notifications, and barcode scanning.**  

## **✨ Features**  

### **🔐 Authentication**  
- **Email/Password Sign Up and Login**  
- **Email Verification & Password Reset**  
- **Google Sign-In Integration**  
- **Secure Authentication via Firebase**  

### **📦 Storage Management**  
- Manage **Multiple Storage Areas** (Refrigerator, Freezer, Pantry, etc.)  
- Track **Product Details**:  
  - Name  
  - Category  
  - Manufacturing Date  
  - Expiry Date (with alerts)  
  - Quantity and Unit  
  - Additional Notes  
- **Details Recognition** using OpenFoodFacts API  

### **🛍 Shopping List**  
- **Add Items with Quantity & Units**  
- **Real-time Updates**  
- **Mark Items as Complete**  
- **Batch Delete Completed Items**  
- **Quick Add Functionality**  
- **Barcode Scanning for Quick Item Addition**  

### **📸 Product Image Support**  
- **Scan Barcodes** to auto-fetch product details via **OpenFoodFacts API**  
- **Capture and Upload Images** for grocery items  
- **OCR Recognition** for expiry dates  

### **🌟 Responsive Design**  
- **Optimized for Mobile & Tablet**  
- **Portrait & Landscape Support**  
- **Adaptive Layouts for Different Screen Sizes**  

## **🛠 Technology Stack**  

- **Frontend**: Flutter  
- **Backend**: Firebase  
  - Authentication  
  - Cloud Firestore  
  - Real-time Database  
- **External API**: [OpenFoodFacts API](https://openfoodfacts.org/) for product details  

## **📌 Prerequisites**  

- **Flutter (Latest Version)**  
- **Dart SDK**  
- **Firebase Account**  
- **Android Studio / VS Code**  
- **Git**  

## **⚡ Installation**  

1. Clone the repository  
```bash  
git clone https://github.com/Black-Lights/grocery_app.git  
```  

2. Navigate to the project directory  
```bash  
cd grocery_app  
```  

3. Install dependencies  
```bash  
flutter pub get  
```  

4. Configure Firebase  
   - Create a **Firebase project**  
   - Add Android/iOS apps in **Firebase console**  
   - Download & add **configuration files**  
   - Enable **Authentication methods** (Email/Password & Google Sign-In)  
   - Set up **Cloud Firestore**  

5. Run the app  
```bash  
flutter run  
```  

## **🔥 Firebase Configuration**  

### **Firestore Rules**  
```javascript  
rules_version = '2';  
service cloud.firestore {  
  match /databases/{database}/documents {  
    match /users/{userId} {  
      allow read, write: if request.auth != null && request.auth.uid == userId;  
      
      match /areas/{areaId} {  
        allow read, write: if request.auth != null && request.auth.uid == userId;  
      }  
      
      match /shopping_list/{itemId} {  
        allow read, write: if request.auth != null && request.auth.uid == userId;  
      }  
    }  
  }  
}  
```  

## **📂 Project Structure**  

```
lib/
├── models/
│   ├── area.dart
│   ├── product.dart
│   ├── shopping_item.dart
├── services/
│   ├── firestore_service.dart
│   ├── shopping_service.dart
│   ├── barcode_scanner.dart
│   └── openfoodfacts_service.dart
├── pages/
│   ├── login.dart
│   ├── signup.dart
│   ├── forgot_password.dart
│   ├── verify.dart
│   ├── homepage.dart
│   ├── shopping_list_page.dart
│   ├── product_details_page.dart
│   └── settings_page.dart
└── main.dart
```  

## **🚀 Features in Detail**  

### **📦 Storage Areas**  
- Default storage areas provided  
- Add **custom storage areas**  
- View **products by area**  
- **Track expiry dates** with notifications  
- Manage **quantities**  

### **📌 Product Management**  
- Add **products with details**  
- **Track expiry dates** (with alerts)  
- Monitor **quantities**  
- Add **notes & categorize products**  
- **Scan barcodes for quick entry**  
- **Fetch product details from OpenFoodFacts API**  

### **🛍 Shopping List**  
- **Quick add items**  
- Specify **quantities & units**  
- **Mark items as purchased**  
- **Clear completed items**  
- **Real-time updates**  
- **Barcode scanning for faster entry**  

## **📱 Responsive Design**  

The app is designed to work seamlessly across **different devices and orientations**:  

### **📱 Mobile**  
- **Portrait**: Optimized **single-column layout**  
- **Landscape**: Adapted **two-column layout**  

### **📟 Tablet**  
- **Enhanced spacing & typography**  
- **Optimized input fields**  
- **Better use of available space**  
- **Side-by-side layouts where appropriate**  

## **🛠 Contributing**  

1. **Fork the repository**  
2. **Create your feature branch** (`git checkout -b feature/AmazingFeature`)  
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)  
4. **Push to the branch** (`git push origin feature/AmazingFeature`)  
5. **Open a Pull Request**  

## **📜 License**  

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.  

## **🙌 Acknowledgments**  

- **Firebase** for backend services  
- **Flutter team** for the amazing framework  
- **GetX** for state management  
- **OpenFoodFacts** for barcode product details  
- **All contributors and testers**  

## **📞 Contact**  


Project Link: [https://github.com/Black-Lights/grocery_app](https://github.com/Black-Lights/grocery_app)  

## **📸 Screenshots**  

![SS_Mob_login](https://github.com/user-attachments/assets/12e278de-88c1-4a4f-b16c-88378bf63db7)

![2025-04-23 17-58-41 High Res Screenshot](https://github.com/user-attachments/assets/71325ca1-e14a-43b9-94d4-18e33d28547d)

![2025-04-23 17-59-26 High Res Screenshot](https://github.com/user-attachments/assets/f6867fce-14c3-4480-bf75-4f861e9cf3c0)

![2025-04-23 18-00-05 High Res Screenshot](https://github.com/user-attachments/assets/bdcc367b-1d0c-45ed-817e-31678bb046d7)

![2025-04-23 18-00-15 High Res Screenshot](https://github.com/user-attachments/assets/742aeea4-a23b-4525-acc5-94af5a125620)

## **🚀 Future Enhancements**  

- **Enhanced Product Image Support**  
- **Improved Expiry Recognition using OCR**  
- **Shopping List Sharing**  
- **Detailed Statistics & Analytics**  
- **Multiple Themes**  
- **Language Support**  

---  
Made with ❤️ by **Ammar and Moldir**
