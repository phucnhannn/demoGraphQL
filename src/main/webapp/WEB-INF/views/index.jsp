<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Demo GraphQL - Main Page</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <div class="container mt-4">
        <h1>Demo GraphQL Application</h1>
        
        <nav class="nav nav-pills mt-3">
            <a class="nav-link active" href="/">Home</a>
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/users">Users</a>
            <a class="nav-link" href="/categories">Categories</a>
        </nav>

        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5>Quick Actions</h5>
                    </div>
                    <div class="card-body">
                        <button class="btn btn-primary btn-sm mb-2" onclick="loadProductsByPrice()">
                            Products by Price (Low to High)
                        </button><br>
                        <select id="categorySelect" class="form-select mb-2">
                            <option value="">Select Category</option>
                            <c:forEach var="category" items="${categories}">
                                <option value="${category.id}">${category.name}</option>
                            </c:forEach>
                        </select>
                        <button class="btn btn-info btn-sm" onclick="loadProductsByCategory()">
                            Load Products by Category
                        </button>
                    </div>
                </div>
            </div>
            
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h5>Results</h5>
                    </div>
                    <div class="card-body">
                        <div id="results">
                            <p>Use the buttons on the left to load data...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5>GraphQL Playground</h5>
                    </div>
                    <div class="card-body">
                        <p>Access GraphQL Playground at: <a href="/graphiql" target="_blank">/graphiql</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function loadProductsByPrice() {
            const query = `
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
            `;
            
            executeGraphQLQuery(query, 'Products sorted by price (Low to High)');
        }

        function loadProductsByCategory() {
            const categoryId = document.getElementById('categorySelect').value;
            if (!categoryId) {
                alert('Please select a category first!');
                return;
            }

            const query = `
                query {
                    getProductsByCategoryId(categoryId: ${categoryId}) {
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
            `;
            
            executeGraphQLQuery(query, 'Products by selected category');
        }

        function executeGraphQLQuery(query, title) {
            $.ajax({
                url: '/graphql',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ query: query }),
                success: function(response) {
                    if (response.errors) {
                        $('#results').html('<div class="alert alert-danger">Error: ' + JSON.stringify(response.errors) + '</div>');
                    } else {
                        displayResults(response.data, title);
                    }
                },
                error: function(xhr, status, error) {
                    $('#results').html('<div class="alert alert-danger">Request failed: ' + error + '</div>');
                }
            });
        }

        function displayResults(data, title) {
            let html = '<h6>' + title + '</h6>';
            
            if (data.getProductsOrderByPriceAsc || data.getProductsByCategoryId) {
                const products = data.getProductsOrderByPriceAsc || data.getProductsByCategoryId;
                if (products.length === 0) {
                    html += '<p>No products found.</p>';
                } else {
                    html += '<div class="table-responsive"><table class="table table-striped table-sm">';
                    html += '<thead><tr><th>ID</th><th>Title</th><th>Price</th><th>Quantity</th><th>User</th><th>Category</th></tr></thead><tbody>';
                    
                    products.forEach(product => {
                        html += '<tr>';
                        html += '<td>' + product.id + '</td>';
                        html += '<td>' + product.title + '</td>';
                        html += '<td>$' + product.price + '</td>';
                        html += '<td>' + (product.quantity || 0) + '</td>';
                        html += '<td>' + (product.user ? product.user.fullname : 'N/A') + '</td>';
                        html += '<td>' + (product.category ? product.category.name : 'N/A') + '</td>';
                        html += '</tr>';
                    });
                    
                    html += '</tbody></table></div>';
                }
            }
            
            $('#results').html(html);
        }
    </script>
</body>
</html>