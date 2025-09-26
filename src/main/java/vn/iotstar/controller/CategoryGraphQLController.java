package vn.iotstar.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;
import vn.iotstar.entity.Category;
import vn.iotstar.service.CategoryService;

import java.util.List;
import java.util.Map;

@Controller
public class CategoryGraphQLController {

    @Autowired
    private CategoryService categoryService;

    @QueryMapping
    public List<Category> getAllCategories() {
        return categoryService.getAllCategories();
    }

    @QueryMapping
    public Category getCategoryById(@Argument Long id) {
        return categoryService.getCategoryById(id).orElse(null);
    }

    @MutationMapping
    public Category createCategory(@Argument Map<String, Object> input) {
        Category category = new Category();
        category.setName((String) input.get("name"));
        category.setImages((String) input.get("images"));
        
        return categoryService.createCategory(category);
    }

    @MutationMapping
    public Category updateCategory(@Argument Long id, @Argument Map<String, Object> input) {
        Category category = new Category();
        category.setName((String) input.get("name"));
        category.setImages((String) input.get("images"));
        
        return categoryService.updateCategory(id, category);
    }

    @MutationMapping
    public Boolean deleteCategory(@Argument Long id) {
        try {
            categoryService.deleteCategory(id);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}