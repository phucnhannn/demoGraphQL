<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Users Management - GraphQL</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <div class="container mt-4">
        <h1>Users Management</h1>
        
        <nav class="nav nav-pills mt-3">
            <a class="nav-link" href="/">Home</a>
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link active" href="/users">Users</a>
            <a class="nav-link" href="/categories">Categories</a>
        </nav>

        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5>Add/Edit User</h5>
                    </div>
                    <div class="card-body">
                        <form id="userForm">
                            <input type="hidden" id="userId" name="id">
                            <div class="mb-3">
                                <label for="fullname" class="form-label">Full Name</label>
                                <input type="text" class="form-control" id="fullname" name="fullname" required>
                            </div>
                            <div class="mb-3">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" name="email" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                            </div>
                            <div class="mb-3">
                                <label for="phone" class="form-label">Phone</label>
                                <input type="tel" class="form-control" id="phone" name="phone">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Categories</label>
                                <div id="categoryCheckboxes">
                                    <c:forEach var="category" items="${categories}">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" value="${category.id}" id="cat_${category.id}" name="categoryIds">
                                            <label class="form-check-label" for="cat_${category.id}">
                                                ${category.name}
                                            </label>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary">Save User</button>
                            <button type="button" class="btn btn-secondary" onclick="clearForm()">Clear</button>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between">
                        <h5>Users List</h5>
                        <button class="btn btn-info btn-sm" onclick="loadAllUsers()">Refresh</button>
                    </div>
                    <div class="card-body">
                        <div id="usersTable">
                            Loading users...
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            loadAllUsers();
            
            $('#userForm').submit(function(e) {
                e.preventDefault();
                saveUser();
            });
        });

        function loadAllUsers() {
            const query = `
                query {
                    getAllUsers {
                        id
                        fullname
                        email
                        phone
                        categories {
                            id
                            name
                        }
                        products {
                            id
                            title
                        }
                    }
                }
            `;
            
            executeGraphQLQuery(query, function(data) {
                displayUsersTable(data.getAllUsers);
            });
        }

        function saveUser() {
            const userId = $('#userId').val();
            const isUpdate = userId && userId !== '';
            
            const categoryIds = [];
            $('input[name="categoryIds"]:checked').each(function() {
                categoryIds.push(parseInt($(this).val()));
            });

            // Get form values and escape them properly
            const fullname = $('#fullname').val().replace(/"/g, '\\"').replace(/\\/g, '\\\\');
            const email = $('#email').val().replace(/"/g, '\\"').replace(/\\/g, '\\\\');
            const password = $('#password').val().replace(/"/g, '\\"').replace(/\\/g, '\\\\');
            const phone = $('#phone').val().replace(/"/g, '\\"').replace(/\\/g, '\\\\');

            // Fix categoryIds array formatting
            const categoryIdsStr = categoryIds.length > 0 ? '[' + categoryIds.join(',') + ']' : '[]';
            
            const mutation = isUpdate ? 
                'mutation {' +
                    'updateUser(id: ' + userId + ', input: {' +
                        'fullname: "' + fullname + '",' +
                        'email: "' + email + '",' +
                        'password: "' + password + '",' +
                        'phone: "' + phone + '",' +
                        'categoryIds: ' + categoryIdsStr +
                    '}) {' +
                        'id ' +
                        'fullname ' +
                        'email' +
                    '}' +
                '}' :
                'mutation {' +
                    'createUser(input: {' +
                        'fullname: "' + fullname + '",' +
                        'email: "' + email + '",' +
                        'password: "' + password + '",' +
                        'phone: "' + phone + '",' +
                        'categoryIds: ' + categoryIdsStr +
                    '}) {' +
                        'id ' +
                        'fullname ' +
                        'email' +
                    '}' +
                '}';

            // Debug: log the mutation to console
            console.log('GraphQL Mutation:', mutation);

            executeGraphQLQuery(mutation, function(data) {
                alert(isUpdate ? 'User updated successfully!' : 'User created successfully!');
                clearForm();
                loadAllUsers();
            });
        }

        function editUser(id, fullname, email, phone, categories) {
            $('#userId').val(id);
            $('#fullname').val(fullname);
            $('#email').val(email);
            $('#password').val(''); // Don't pre-fill password for security
            $('#phone').val(phone);
            
            // Clear all checkboxes first
            $('input[name="categoryIds"]').prop('checked', false);
            
            // Check the categories this user belongs to
            if (categories && categories.length > 0) {
                categories.forEach(category => {
                    $('#cat_' + category.id).prop('checked', true);
                });
            }
        }

        function deleteUser(id) {
            if (confirm('Are you sure you want to delete this user? This will also delete all their products!')) {
                const mutation = 'mutation { deleteUser(id: ' + id + ') }';
                
                // Debug: log the mutation to console
                console.log('Delete Mutation:', mutation);
                
                executeGraphQLQuery(mutation, function(data) {
                    if (data.deleteUser) {
                        alert('User deleted successfully!');
                        loadAllUsers();
                    } else {
                        alert('Failed to delete user!');
                    }
                });
            }
        }

        function clearForm() {
            $('#userForm')[0].reset();
            $('#userId').val('');
            $('input[name="categoryIds"]').prop('checked', false);
        }

        function displayUsersTable(users) {
            let html = '<div class="table-responsive"><table class="table table-striped">';
            html += '<thead><tr><th>ID</th><th>Full Name</th><th>Email</th><th>Phone</th><th>Categories</th><th>Products</th><th>Actions</th></tr></thead><tbody>';
            
            if (users && users.length > 0) {
                users.forEach(user => {
                    html += '<tr>';
                    html += '<td>' + user.id + '</td>';
                    html += '<td>' + user.fullname + '</td>';
                    html += '<td>' + user.email + '</td>';
                    html += '<td>' + (user.phone || 'N/A') + '</td>';
                    
                    // Categories
                    html += '<td>';
                    if (user.categories && user.categories.length > 0) {
                        const categoryNames = user.categories.map(c => c.name).join(', ');
                        html += '<small>' + categoryNames + '</small>';
                    } else {
                        html += '<small class="text-muted">None</small>';
                    }
                    html += '</td>';
                    
                    // Products count
                    html += '<td>';
                    if (user.products && user.products.length > 0) {
                        html += '<span class="badge bg-info">' + user.products.length + ' products</span>';
                    } else {
                        html += '<span class="badge bg-secondary">0 products</span>';
                    }
                    html += '</td>';
                    
                    html += '<td>';
                    // Escape quotes in user data for JavaScript
                    const escapedFullname = user.fullname.replace(/'/g, "\\'");
                    const escapedEmail = user.email.replace(/'/g, "\\'");
                    const escapedPhone = (user.phone || '').replace(/'/g, "\\'");
                    const categoriesJson = JSON.stringify(user.categories || []).replace(/"/g, '\\"');
                    
                    html += '<button class="btn btn-sm btn-warning me-1" onclick="editUser(' + 
                            user.id + ',\'' + escapedFullname + '\',\'' + escapedEmail + '\',\'' + 
                            escapedPhone + '\',' + categoriesJson + ')">Edit</button>';
                    html += '<button class="btn btn-sm btn-danger" onclick="deleteUser(' + user.id + ')">Delete</button>';
                    html += '</td>';
                    html += '</tr>';
                });
            } else {
                html += '<tr><td colspan="7" class="text-center">No users found</td></tr>';
            }
            
            html += '</tbody></table></div>';
            $('#usersTable').html(html);
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