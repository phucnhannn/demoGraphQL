# Demo GraphQL Project với Spring Boot 3

## Mô tả
Project demo GraphQL API với Spring Boot 3 bao gồm các chức năng CRUD cho 3 bảng: Category, User, Product với các mối quan hệ:
- User và Category: Many-to-Many
- User và Product: One-to-Many  
- Category và Product: One-to-Many

## Cấu trúc Database
```sql
-- Bảng users
CREATE TABLE users (
    id BIGINT IDENTITY PRIMARY KEY,
    fullname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(255)
);

-- Bảng categories  
CREATE TABLE categories (
    id BIGINT IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    images VARCHAR(255)
);

-- Bảng products
CREATE TABLE products (
    id BIGINT IDENTITY PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    quantity INT,
    description VARCHAR(255),
    price DECIMAL(38,2) NOT NULL,
    user_id BIGINT NOT NULL,
    category_id BIGINT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Bảng liên kết user_category (Many-to-Many)
CREATE TABLE user_category (
    user_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, category_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

## Cách chạy ứng dụng

1. **Khởi động ứng dụng:**
   ```bash
   mvn spring-boot:run
   ```

2. **Truy cập các URL:**
   - Trang chủ: http://localhost:8088
   - Quản lý Products: http://localhost:8088/products
   - Quản lý Users: http://localhost:8088/users  
   - Quản lý Categories: http://localhost:8088/categories
   - GraphQL Playground: http://localhost:8088/graphiql

## Các chức năng chính

### 1. Hiển thị tất cả product có price từ thấp đến cao
**GraphQL Query:**
```graphql
query {
  getProductsOrderByPriceAsc {
    id
    title
    price
    quantity
    desc
    user {
      fullname
    }
    category {
      name
    }
  }
}
```

### 2. Lấy tất cả product của một category
**GraphQL Query:**
```graphql
query {
  getProductsByCategoryId(categoryId: 1) {
    id
    title
    price
    quantity
    user {
      fullname
    }
    category {
      name
    }
  }
}
```

### 3. CRUD Operations

#### Product CRUD
```graphql
# Tạo Product
mutation {
  createProduct(input: {
    title: "iPhone 15"
    price: 999.99
    quantity: 10
    desc: "Latest iPhone"
    userId: 1
    categoryId: 1
  }) {
    id
    title
    price
  }
}

# Cập nhật Product
mutation {
  updateProduct(id: 1, input: {
    title: "iPhone 15 Pro"
    price: 1199.99
    quantity: 5
    desc: "iPhone 15 Pro Max"
    userId: 1
    categoryId: 1
  }) {
    id
    title
    price
  }
}

# Xóa Product
mutation {
  deleteProduct(id: 1)
}

# Lấy tất cả Products
query {
  getAllProducts {
    id
    title
    price
    quantity
    user {
      fullname
    }
    category {
      name
    }
  }
}
```

#### User CRUD
```graphql
# Tạo User
mutation {
  createUser(input: {
    fullname: "Nguyen Van A"
    email: "nguyenvana@email.com"
    password: "123456"
    phone: "0123456789"
    categoryIds: [1, 2]
  }) {
    id
    fullname
    email
  }
}

# Cập nhật User
mutation {
  updateUser(id: 1, input: {
    fullname: "Nguyen Van B"
    email: "nguyenvanb@email.com"
    password: "654321"
    phone: "0987654321"
    categoryIds: [2, 3]
  }) {
    id
    fullname
    email
  }
}

# Xóa User
mutation {
  deleteUser(id: 1)
}

# Lấy tất cả Users
query {
  getAllUsers {
    id
    fullname
    email
    phone
    categories {
      name
    }
    products {
      title
    }
  }
}
```

#### Category CRUD
```graphql
# Tạo Category
mutation {
  createCategory(input: {
    name: "Electronics"
    images: "https://example.com/electronics.jpg"
  }) {
    id
    name
    images
  }
}

# Cập nhật Category
mutation {
  updateCategory(id: 1, input: {
    name: "Mobile Phones"
    images: "https://example.com/phones.jpg"
  }) {
    id
    name
    images
  }
}

# Xóa Category
mutation {
  deleteCategory(id: 1)
}

# Lấy tất cả Categories
query {
  getAllCategories {
    id
    name
    images
    products {
      title
    }
    users {
      fullname
    }
  }
}
```

## Tính năng Web Interface

### 1. Trang chính (/)
- Hiển thị các nút quick action để test GraphQL queries
- Load products sorted by price
- Load products by category

### 2. Trang Products (/products)
- Hiển thị danh sách tất cả products
- Form thêm/sửa product
- Chức năng xóa product
- Sắp xếp products theo giá

### 3. Trang Users (/users)  
- Hiển thị danh sách users
- Form thêm/sửa user với many-to-many categories
- Chức năng xóa user

### 4. Trang Categories (/categories)
- Hiển thị danh sách categories
- Form thêm/sửa category
- Xem products của từng category
- Chức năng xóa category

## Công nghệ sử dụng
- **Spring Boot 3.5.6**
- **Spring Data JPA**
- **Spring GraphQL** 
- **Hibernate**
- **SQL Server**
- **Lombok**
- **JSP + JSTL**
- **Bootstrap 5**
- **jQuery**
- **AJAX**

## Cấu hình Database
File `application.properties` đã được cấu hình để kết nối với SQL Server:
```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=demoGraphQL;encrypt=true;trustServerCertificate=true
spring.datasource.username=sa
spring.datasource.password=1
spring.jpa.hibernate.ddl-auto=update
```

Ứng dụng sẽ tự động tạo database và các bảng khi khởi động lần đầu.