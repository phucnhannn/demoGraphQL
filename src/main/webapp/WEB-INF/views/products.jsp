<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Products Management - GraphQL</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <div class="container mt-4">
        <h1>Products Management</h1>
        
        <nav class="nav nav-pills mt-3">
            <a class="nav-link" href="/">Home</a>
            <a class="nav-link active" href="/products">Products</a>
            <a class="nav-link" href="/users">Users</a>
            <a class="nav-link" href="/categories">Categories</a>
        </nav>

        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5>Add/Edit Product</h5>
                    </div>
                    <div class="card-body">
                        <form id="productForm">
                            <input type="hidden" id="productId" name="id">
                            <div class="mb-3">
                                <label for="title" class="form-label">Title</label>
                                <input type="text" class="form-control" id="title" name="title" required>
                            </div>
                            <div class="mb-3">
                                <label for="price" class="form-label">Price</label>
                                <input type="number" step="0.01" class="form-control" id="price" name="price" required>
                            </div>
                            <div class="mb-3">
                                <label for="quantity" class="form-label">Quantity</label>
                                <input type="number" class="form-control" id="quantity" name="quantity">
                            </div>
                            <div class="mb-3">
                                <label for="desc" class="form-label">Description</label>
                                <textarea class="form-control" id="desc" name="desc" rows="3"></textarea>
                            </div>
                            <div class="mb-3">
                                <label for="userId" class="form-label">User</label>
                                <select class="form-select" id="userId" name="userId" required>
                                    <option value="">Select User</option>
                                    <c:forEach var="user" items="${users}">
                                        <option value="${user.id}">${user.fullname}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="categoryId" class="form-label">Category</label>
                                <select class="form-select" id="categoryId" name="categoryId">
                                    <option value="">Select Category</option>
                                    <c:forEach var="category" items="${categories}">
                                        <option value="${category.id}">${category.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary">Save Product</button>
                            <button type="button" class="btn btn-secondary" onclick="clearForm()">Clear</button>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between">
                        <h5>Products List</h5>
                        <div>
                            <button class="btn btn-info btn-sm" onclick="loadAllProducts()">Refresh</button>
                            <button class="btn btn-success btn-sm" onclick="loadProductsByPrice()">Sort by Price</button>
                        </div>
                    </div>
                    <div class="card-body">
                        <div id="productsTable">
                            Loading products...
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            loadAllProducts();
            
            $('#productForm').submit(function(e) {
                e.preventDefault();
                saveProduct();
            });
        });

        function loadAllProducts() {
            const query = `query { getAllProducts { id title price quantity desc user { id fullname } category { id name } } }`;
            executeGraphQL(query, {}, function(data) {
                displayProductsTable(data.getAllProducts);
            });
        }

        function loadProductsByPrice() {
            const query = `query { getProductsOrderByPriceAsc { id title price quantity desc user { id fullname } category { id name } } }`;
            executeGraphQL(query, {}, function(data) {
                displayProductsTable(data.getProductsOrderByPriceAsc);
            });
        }

        function saveProduct() {
            const productId = $('#productId').val();
            const isUpdate = productId && productId !== '';
            
            const input = {
                title: $('#title').val(),
                price: parseFloat($('#price').val()),
                quantity: $('#quantity').val() ? parseInt($('#quantity').val()) : null,
                desc: $('#desc').val(),
                userId: parseInt($('#userId').val()),
                categoryId: $('#categoryId').val() ? parseInt($('#categoryId').val()) : null
            };

            const mutation = isUpdate ?
                `mutation UpdateProduct($id: ID!, $input: ProductInput!) { updateProduct(id: $id, input: $input) { id title price } }` :
                `mutation CreateProduct($input: ProductInput!) { createProduct(input: $input) { id title price } }`;

            const variables = isUpdate ? { id: productId, input } : { input };

            executeGraphQL(mutation, variables, function() {
                alert(isUpdate ? 'Product updated successfully!' : 'Product created successfully!');
                clearForm();
                loadAllProducts();
            });
        }

        function editProductFromButton(btn) {
            const product = JSON.parse(btn.getAttribute('data-product'));
            $('#productId').val(product.id);
            $('#title').val(product.title || '');
            $('#price').val(product.price != null ? product.price : '');
            $('#quantity').val(product.quantity != null ? product.quantity : '');
            $('#desc').val(product.desc || '');
            $('#userId').val(product.user ? product.user.id : '');
            $('#categoryId').val(product.category ? product.category.id : '');
        }

        function deleteProduct(id) {
            if (confirm('Are you sure you want to delete this product?')) {
                const mutation = `mutation DeleteProduct($id: ID!) { deleteProduct(id: $id) }`;
                executeGraphQL(mutation, { id }, function(data) {
                    if (data.deleteProduct) {
                        alert('Product deleted successfully!');
                        loadAllProducts();
                    } else {
                        alert('Failed to delete product!');
                    }
                });
            }
        }

        function clearForm() {
            $('#productForm')[0].reset();
            $('#productId').val('');
        }

        function displayProductsTable(products) {
            let html = '<div class="table-responsive"><table class="table table-striped">';
            html += '<thead><tr><th>ID</th><th>Title</th><th>Price</th><th>Qty</th><th>User</th><th>Category</th><th>Actions</th></tr></thead><tbody>';
            
            if (products && products.length > 0) {
                products.forEach(product => {
                    const dataAttr = JSON.stringify(product)
                        .replace(/&/g, '&amp;')
                        .replace(/"/g, '&quot;')
                        .replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;');

                    html += '<tr>';
                    html += '<td>' + product.id + '</td>';
                    html += '<td>' + (product.title || '') + '</td>';
                    html += '<td>$' + product.price + '</td>';
                    html += '<td>' + (product.quantity || 0) + '</td>';
                    html += '<td>' + (product.user ? product.user.fullname : 'N/A') + '</td>';
                    html += '<td>' + (product.category ? product.category.name : 'N/A') + '</td>';
                    html += '<td>';
                    html += '<button class="btn btn-sm btn-warning me-1" data-product="' + dataAttr + '" onclick="editProductFromButton(this)">Edit</button>';
                    html += '<button class="btn btn-sm btn-danger" onclick="deleteProduct(' + product.id + ')">Delete</button>';
                    html += '</td>';
                    html += '</tr>';
                });
            } else {
                html += '<tr><td colspan="7" class="text-center">No products found</td></tr>';
            }
            
            html += '</tbody></table></div>';
            $('#productsTable').html(html);
        }

        function executeGraphQL(query, variables, successCallback) {
            $.ajax({
                url: '/graphql',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ query: query, variables: variables || {} }),
                success: function(response) {
                    if (response.errors) {
                        alert('GraphQL Error: ' + JSON.stringify(response.errors));
                    } else {
                        successCallback(response.data);
                    }
                },
                error: function(xhr, status, error) {
                    alert('Request failed: ' + error);
                }
            });
        }
    </script>
</body>
</html>