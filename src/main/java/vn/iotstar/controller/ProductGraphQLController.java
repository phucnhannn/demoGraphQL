package vn.iotstar.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;
import vn.iotstar.entity.Product;
import vn.iotstar.entity.User;
import vn.iotstar.entity.Category;
import vn.iotstar.service.ProductService;
import vn.iotstar.service.UserService;
import vn.iotstar.service.CategoryService;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Controller
public class ProductGraphQLController {

    @Autowired
    private ProductService productService;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private CategoryService categoryService;

    @QueryMapping
    public List<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    @QueryMapping
    public Product getProductById(@Argument Long id) {
        return productService.getProductById(id).orElse(null);
    }

    @QueryMapping
    public List<Product> getProductsOrderByPriceAsc() {
        return productService.getAllProductsOrderByPriceAsc();
    }

    @QueryMapping
    public List<Product> getProductsByCategoryId(@Argument Long categoryId) {
        return productService.getProductsByCategoryId(categoryId);
    }

    @MutationMapping
    public Product createProduct(@Argument Map<String, Object> input) {
        Product product = new Product();
        product.setTitle((String) input.get("title"));
        Object q = input.get("quantity");
        if (q != null) product.setQuantity(((Number) q).intValue());
        product.setDesc((String) input.get("desc"));
        Object pr = input.get("price");
        if (pr == null) throw new RuntimeException("Price is required");
        product.setPrice(BigDecimal.valueOf(((Number) pr).doubleValue()));
        
        Object uid = input.get("userId");
        if (uid == null) throw new RuntimeException("UserId is required");
        Long userId = Long.valueOf(String.valueOf(uid));
        User user = userService.getUserById(userId).orElseThrow(() -> 
            new RuntimeException("User not found with id: " + userId));
        product.setUser(user);
        
        Object cid = input.get("categoryId");
        if (cid != null) {
            Long categoryId = Long.valueOf(String.valueOf(cid));
            Category category = categoryService.getCategoryById(categoryId).orElseThrow(() -> 
                new RuntimeException("Category not found with id: " + categoryId));
            product.setCategory(category);
        }
        
        return productService.createProduct(product);
    }

    @MutationMapping
    public Product updateProduct(@Argument Long id, @Argument Map<String, Object> input) {
        Product product = new Product();
        product.setTitle((String) input.get("title"));
        Object q = input.get("quantity");
        if (q != null) product.setQuantity(((Number) q).intValue());
        product.setDesc((String) input.get("desc"));
        Object pr = input.get("price");
        if (pr != null) {
            product.setPrice(BigDecimal.valueOf(((Number) pr).doubleValue()));
        }
        
        Object uid = input.get("userId");
        if (uid == null) throw new RuntimeException("UserId is required");
        Long userId = Long.valueOf(String.valueOf(uid));
        User user = userService.getUserById(userId).orElseThrow(() -> 
            new RuntimeException("User not found with id: " + userId));
        product.setUser(user);
        
        Object cid = input.get("categoryId");
        if (cid != null) {
            Long categoryId = Long.valueOf(String.valueOf(cid));
            Category category = categoryService.getCategoryById(categoryId).orElseThrow(() -> 
                new RuntimeException("Category not found with id: " + categoryId));
            product.setCategory(category);
        }
        
        return productService.updateProduct(id, product);
    }

    @MutationMapping
    public Boolean deleteProduct(@Argument Long id) {
        try {
            productService.deleteProduct(id);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}