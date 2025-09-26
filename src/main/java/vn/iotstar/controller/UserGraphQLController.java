package vn.iotstar.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;
import vn.iotstar.entity.User;
import vn.iotstar.entity.Category;
import vn.iotstar.service.UserService;
import vn.iotstar.service.CategoryService;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Controller
public class UserGraphQLController {

    @Autowired
    private UserService userService;
    
    @Autowired
    private CategoryService categoryService;

    @QueryMapping
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }

    @QueryMapping
    public User getUserById(@Argument Long id) {
        return userService.getUserById(id).orElse(null);
    }

    @MutationMapping
    public User createUser(@Argument Map<String, Object> input) {
        try {
            User user = new User();
            user.setFullname((String) input.get("fullname"));
            user.setEmail((String) input.get("email"));
            user.setPassword((String) input.get("password"));
            user.setPhone((String) input.get("phone"));
            
            // Handle many-to-many relationship with categories
            Object cats = input.get("categoryIds");
            if (cats instanceof List<?>) {
                List<?> categoryIds = (List<?>) cats;
                if (!categoryIds.isEmpty()) {
                    Set<Category> categories = new HashSet<>();
                    for (Object catId : categoryIds) {
                        try {
                            Long cid = Long.valueOf(String.valueOf(catId));
                            Category category = categoryService.getCategoryById(cid)
                                .orElseThrow(() -> new RuntimeException("Category not found with id: " + cid));
                            categories.add(category);
                        } catch (NumberFormatException e) {
                            throw new RuntimeException("Invalid category ID format: " + catId);
                        }
                    }
                    user.setCategories(categories);
                }
            }
            
            return userService.createUser(user);
        } catch (Exception e) {
            System.err.println("Error creating user: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to create user: " + e.getMessage(), e);
        }
    }

    @MutationMapping
    public User updateUser(@Argument Long id, @Argument Map<String, Object> input) {
        User user = new User();
        user.setFullname((String) input.get("fullname"));
        user.setEmail((String) input.get("email"));
        user.setPassword((String) input.get("password"));
        user.setPhone((String) input.get("phone"));
        
        // Handle many-to-many relationship with categories (only if provided)
        Object cats = input.get("categoryIds");
        if (cats instanceof List<?>) {
            List<?> categoryIds = (List<?>) cats;
            Set<Category> categories = new HashSet<>();
            for (Object catId : categoryIds) {
                Long cid = Long.valueOf(String.valueOf(catId));
                Category category = categoryService.getCategoryById(cid)
                    .orElseThrow(() -> new RuntimeException("Category not found with id: " + cid));
                categories.add(category);
            }
            user.setCategories(categories);
        }
        
        return userService.updateUser(id, user);
    }

    @MutationMapping
    public Boolean deleteUser(@Argument Long id) {
        try {
            userService.deleteUser(id);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}