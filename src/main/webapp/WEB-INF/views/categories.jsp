<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Categories Management - GraphQL</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <div class="container mt-4">
        <h1>Categories Management</h1>
        
        <nav class="nav nav-pills mt-3">
            <a class="nav-link" href="/">Home</a>
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/users">Users</a>
            <a class="nav-link active" href="/categories">Categories</a>
        </nav>

        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5>Add/Edit Category</h5>
                    </div>
                    <div class="card-body">
                        <form id="categoryForm">
                            <input type="hidden" id="categoryId" name="id">
                            <div class="mb-3">
                                <label for="name" class="form-label">Category Name</label>
                                <input type="text" class="form-control" id="name" name="name" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Category Image</label>
                                <div class="mb-2">
                                    <label for="imageFile" class="form-label">Upload Image from Computer</label>
                                    <input type="file" class="form-control" id="imageFile" name="imageFile" accept="image/*">
                                    <div class="form-text">Choose an image file from your computer</div>
                                </div>
                                <div class="text-center mb-2">
                                    <span class="text-muted">OR</span>
                                </div>
                                <div>
                                    <label for="images" class="form-label">Image URL</label>
                                    <input type="url" class="form-control" id="images" name="images" placeholder="https://example.com/image.jpg">
                                    <div class="form-text">Enter image URL directly</div>
                                </div>
                                <!-- Image preview -->
                                <div id="imagePreview" class="mt-2" style="display: none;">
                                    <img id="previewImg" src="" alt="Preview" style="max-width: 200px; max-height: 150px; object-fit: cover;" class="rounded border">
                                    <button type="button" class="btn btn-sm btn-danger ms-2" onclick="clearImagePreview()">Remove</button>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary">Save Category</button>
                            <button type="button" class="btn btn-secondary" onclick="clearForm()">Clear</button>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between">
                        <h5>Categories List</h5>
                        <button class="btn btn-info btn-sm" onclick="loadAllCategories()">Refresh</button>
                    </div>
                    <div class="card-body">
                        <div id="categoriesTable">
                            Loading categories...
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            loadAllCategories();
            
            $('#categoryForm').submit(function(e) {
                e.preventDefault();
                saveCategory();
            });

            // Preview image on file select
            $('#imageFile').change(function() {
                const file = this.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        $('#previewImg').attr('src', e.target.result);
                        $('#imagePreview').show();
                    }
                    reader.readAsDataURL(file);
                }
            });
        });

        function loadAllCategories() {
            const query = `
                query {
                    getAllCategories {
                        id
                        name
                        images
                        products {
                            id
                            title
                        }
                        users {
                            id
                            fullname
                        }
                    }
                }
            `;
            
            executeGraphQLQuery(query, function(data) {
                displayCategoriesTable(data.getAllCategories);
            });
        }

        function saveCategory() {
            const categoryId = $('#categoryId').val();
            const isUpdate = categoryId && categoryId !== '';
            
            // Kiểm tra nếu có file được chọn để upload
            const fileInput = $('#imageFile')[0];
            if (fileInput.files && fileInput.files.length > 0) {
                // Upload file trước khi save category
                uploadImageFile(fileInput.files[0], function(imageUrl) {
                    // Sau khi upload thành công, save category với URL mới
                    saveCategoryWithImage(categoryId, isUpdate, imageUrl);
                }, function(error) {
                    alert('Failed to upload image: ' + error);
                });
            } else {
                // Không có file upload, dùng URL trực tiếp
                const imageUrl = $('#images').val();
                saveCategoryWithImage(categoryId, isUpdate, imageUrl);
            }
        }

        function uploadImageFile(file, successCallback, errorCallback) {
            const formData = new FormData();
            formData.append('file', file);
            
            $.ajax({
                url: '/api/upload',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    if (response.url) {
                        successCallback(response.url);
                    } else {
                        errorCallback(response.error || 'Upload failed');
                    }
                },
                error: function(xhr, status, error) {
                    errorCallback('Upload request failed: ' + error);
                }
            });
        }

        function saveCategoryWithImage(categoryId, isUpdate, imageUrl) {
            // Get form values and escape them properly
            const name = $('#name').val().replace(/"/g, '\\"').replace(/\\/g, '\\\\');
            const images = imageUrl.replace(/"/g, '\\"').replace(/\\/g, '\\\\');

            const mutation = isUpdate ? 
                'mutation {' +
                    'updateCategory(id: ' + categoryId + ', input: {' +
                        'name: "' + name + '",' +
                        'images: "' + images + '"' +
                    '}) {' +
                        'id ' +
                        'name ' +
                        'images' +
                    '}' +
                '}' :
                'mutation {' +
                    'createCategory(input: {' +
                        'name: "' + name + '",' +
                        'images: "' + images + '"' +
                    '}) {' +
                        'id ' +
                        'name ' +
                        'images' +
                    '}' +
                '}';

            // Debug: log the mutation to console
            console.log('Category Mutation:', mutation);

            executeGraphQLQuery(mutation, function(data) {
                alert(isUpdate ? 'Category updated successfully!' : 'Category created successfully!');
                clearForm();
                loadAllCategories();
            });
        }

        function editCategory(id, name, images) {
            $('#categoryId').val(id);
            $('#name').val(name);
            $('#images').val(images || '');
        }

        function deleteCategory(id) {
            if (confirm('Are you sure you want to delete this category? This may affect related products and users!')) {
                const mutation = 'mutation { deleteCategory(id: ' + id + ') }';
                
                // Debug: log the mutation to console
                console.log('Delete Category Mutation:', mutation);
                
                executeGraphQLQuery(mutation, function(data) {
                    if (data.deleteCategory) {
                        alert('Category deleted successfully!');
                        loadAllCategories();
                    } else {
                        alert('Failed to delete category!');
                    }
                });
            }
        }

        function viewCategoryProducts(categoryId, categoryName) {
            const query = 'query {' +
                'getProductsByCategoryId(categoryId: ' + categoryId + ') {' +
                    'id ' +
                    'title ' +
                    'price ' +
                    'quantity ' +
                    'user {' +
                        'fullname' +
                    '}' +
                '}' +
            '}';
            
            // Debug: log the query to console
            console.log('Category Products Query:', query);
            
            executeGraphQLQuery(query, function(data) {
                displayCategoryProducts(data.getProductsByCategoryId, categoryName);
            });
        }

        function displayCategoryProducts(products, categoryName) {
            let html = '<div class="modal fade" id="productsModal" tabindex="-1">';
            html += '<div class="modal-dialog modal-lg"><div class="modal-content">';
            html += '<div class="modal-header">';
            html += '<h5 class="modal-title">Products in ' + categoryName + '</h5>';
            html += '<button type="button" class="btn-close" data-bs-dismiss="modal"></button>';
            html += '</div><div class="modal-body">';
            
            if (products && products.length > 0) {
                html += '<table class="table table-striped">';
                html += '<thead><tr><th>ID</th><th>Title</th><th>Price</th><th>Quantity</th><th>User</th></tr></thead><tbody>';
                
                products.forEach(product => {
                    html += '<tr>';
                    html += '<td>' + product.id + '</td>';
                    html += '<td>' + product.title + '</td>';
                    html += '<td>$' + product.price + '</td>';
                    html += '<td>' + (product.quantity || 0) + '</td>';
                    html += '<td>' + (product.user ? product.user.fullname : 'N/A') + '</td>';
                    html += '</tr>';
                });
                
                html += '</tbody></table>';
            } else {
                html += '<p>No products found in this category.</p>';
            }
            
            html += '</div><div class="modal-footer">';
            html += '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>';
            html += '</div></div></div></div>';
            
            // Remove existing modal if any
            $('#productsModal').remove();
            $('body').append(html);
            $('#productsModal').modal('show');
        }

        function clearForm() {
            $('#categoryForm')[0].reset();
            $('#categoryId').val('');
            clearImagePreview();
        }

        function clearImagePreview() {
            $('#imageFile').val('');
            $('#previewImg').attr('src', '');
            $('#imagePreview').hide();
        }

        function displayCategoriesTable(categories) {
            let html = '<div class="table-responsive"><table class="table table-striped">';
            html += '<thead><tr><th>ID</th><th>Name</th><th>Image</th><th>Products</th><th>Users</th><th>Actions</th></tr></thead><tbody>';
            
            if (categories && categories.length > 0) {
                categories.forEach(category => {
                    html += '<tr>';
                    html += '<td>' + category.id + '</td>';
                    html += '<td>' + category.name + '</td>';
                    
                    // Image
                    html += '<td>';
                    if (category.images) {
                        html += '<img src="' + category.images + '" alt="' + category.name + '" style="width: 50px; height: 50px; object-fit: cover;" class="rounded">';
                    } else {
                        html += '<span class="text-muted">No image</span>';
                    }
                    html += '</td>';
                    
                    // Products count with link - FIX: escape category name properly
                    html += '<td>';
                    if (category.products && category.products.length > 0) {
                        // Use JSON.stringify to properly escape the category name
                        const escapedCategoryName = JSON.stringify(category.name);
                        html += '<button class="btn btn-link btn-sm p-0" onclick="viewCategoryProducts(' + 
                                category.id + ', ' + escapedCategoryName + ')">';
                        html += '<span class="badge bg-info">' + category.products.length + ' products</span>';
                        html += '</button>';
                    } else {
                        html += '<span class="badge bg-secondary">0 products</span>';
                    }
                    html += '</td>';
                    
                    // Users count
                    html += '<td>';
                    if (category.users && category.users.length > 0) {
                        html += '<span class="badge bg-success">' + category.users.length + ' users</span>';
                    } else {
                        html += '<span class="badge bg-secondary">0 users</span>';
                    }
                    html += '</td>';
                    
                    html += '<td>';
                    const escapedName = category.name.replace(/'/g, "\\'");
                    const escapedImages = (category.images || '').replace(/'/g, "\\'");
                    
                    html += '<button class="btn btn-sm btn-warning me-1" onclick="editCategory(' + 
                            category.id + ',\'' + escapedName + '\',\'' + escapedImages + '\')">Edit</button>';
                    html += '<button class="btn btn-sm btn-danger" onclick="deleteCategory(' + category.id + ')">Delete</button>';
                    html += '</td>';
                    html += '</tr>';
                });
            } else {
                html += '<tr><td colspan="6" class="text-center">No categories found</td></tr>';
            }
            
            html += '</tbody></table></div>';
            $('#categoriesTable').html(html);
        }

        function executeGraphQLQuery(query, successCallback) {
            $.ajax({
                url: '/graphql',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ query: query }),
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