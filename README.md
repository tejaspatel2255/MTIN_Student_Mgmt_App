# MTIN Student Management Portal 🏥

A robust, mobile-first Flutter application designed for the **Manikaka Topawala Institute of Nursing (MTIN)**. This portal empowers nursing students to manage clinical requirements and conduct comprehensive community health surveys with a modern, dynamic UI.

## 🚀 Key Features

### 1. Dynamic Baseline Survey Engine
A powerful, JSON-driven form engine capable of rendering 17 complex clinical and social sections.
*   **Hierarchical Selectors**: Organized categorization of National Health Programmes and Disease Tracking.
*   **Zero-Dropdown Policy**: Optimized for rapid mobile entry using single-tap radio buttons and checkboxes.
*   **Conditional Logic**: Sections and fields dynamically appear/disappear based on student input (e.g., specific community areas based on facility type).

### 2. Advanced Health & Financial Tracking
*   **Family Health Tracker**: Person-specific disease reporting covering 50+ communicable and non-communicable diseases.
*   **Real-time Income Calculator**: Automatically aggregates family member incomes to provide instant total calculations.
*   **Expenditure Summary**: Live calculation of percentage-wise spending across various household categories.

### 3. Mobile-First Architecture
*   **Expandable Card UI**: Complex tables are transformed into sleek, expandable cards to prevent horizontal scrolling and pixel-overflow on mobile devices.
*   **Stateful Form Management**: Robust handling of complex nested data structures (JSONB compatible).

## 🛠️ Tech Stack
*   **Frontend**: Flutter (Provider for State Management)
*   **Backend**: Supabase (PostgreSQL with JSONB storage)
*   **Design System**: Custom Vanilla CSS/Flutter styling with MTIN brand colors.

## 📦 Getting Started

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/tejaspatel2255/MTIN_Student_Mgmt_App.git
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

## 📄 License
This project is developed for the **Manikaka Topawala Institute of Nursing (MTIN)**, Charusat Campus, Changa.
