package vn.iotstar.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.entity.Category;
import vn.iotstar.entity.Product;
import vn.iotstar.entity.User;
import vn.iotstar.repository.CategoryRepository;
import vn.iotstar.repository.ProductRepository;
import vn.iotstar.repository.UserRepository;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Controller
@Transactional
public class GraphQLApi {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private CategoryRepository categoryRepository;
    @Autowired
    private ProductRepository productRepository;

    /* Records for inputs */
    public record UserInput(String fullname, String email, String password, String phone) {}
    public record CategoryInput(String name, String images) {}
    public record ProductInput(String title, Integer quantity, String desc, Double price, Long userId, Long categoryId) {}

    /* =================== QUERIES =================== */
    @QueryMapping
    public List<User> users() {return userRepository.findAll();}

    @QueryMapping
    public User user(@Argument Long id){return userRepository.findById(id).orElse(null);}    

    @QueryMapping
    public List<Category> categories(){return categoryRepository.findAll();}

    @QueryMapping
    public Category category(@Argument Long id){return categoryRepository.findById(id).orElse(null);}    

    @QueryMapping
    public List<Product> products(){return productRepository.findAll();}

    @QueryMapping
    public List<Product> productsSortedByPrice(){return productRepository.findAllByOrderByPriceAsc();}

    @QueryMapping
    public List<Product> productsByCategory(@Argument Long categoryId){return productRepository.findByCategory_Id(categoryId);}    

    /* =================== MUTATIONS USER =================== */
    @MutationMapping
    public User createUser(@Argument UserInput input){
        User u = new User();
        u.setFullname(input.fullname());
        u.setEmail(input.email());
        u.setPassword(input.password());
        u.setPhone(input.phone());
        return userRepository.save(u);
    }

    @MutationMapping
    public User updateUser(@Argument Long id, @Argument UserInput input){
        return userRepository.findById(id).map(u -> {
            if(input.fullname()!=null) u.setFullname(input.fullname());
            if(input.email()!=null) u.setEmail(input.email());
            if(input.password()!=null) u.setPassword(input.password());
            if(input.phone()!=null) u.setPhone(input.phone());
            return userRepository.save(u);
        }).orElse(null);
    }

    @MutationMapping
    public Boolean deleteUser(@Argument Long id){
        if(!userRepository.existsById(id)) return false;
        userRepository.deleteById(id);return true;
    }

    /* =================== MUTATIONS CATEGORY =================== */
    @MutationMapping
    public Category createCategory(@Argument CategoryInput input){
        Category c = new Category();
        c.setName(input.name());
        c.setImages(input.images());
        return categoryRepository.save(c);
    }

    @MutationMapping
    public Category updateCategory(@Argument Long id, @Argument CategoryInput input){
        return categoryRepository.findById(id).map(c -> {
            if(input.name()!=null) c.setName(input.name());
            if(input.images()!=null) c.setImages(input.images());
            return categoryRepository.save(c);
        }).orElse(null);
    }

    @MutationMapping
    public Boolean deleteCategory(@Argument Long id){
        if(!categoryRepository.existsById(id)) return false;
        categoryRepository.deleteById(id);return true;
    }

    /* =================== MUTATIONS PRODUCT =================== */
    @MutationMapping
    public Product createProduct(@Argument ProductInput input){
        Product p = new Product();
        p.setTitle(input.title());
        p.setQuantity(input.quantity());
        p.setDesc(input.desc());
        p.setPrice(input.price());
        if(input.userId()!=null) {
            userRepository.findById(input.userId()).ifPresent(userFound -> p.setUser(userFound));
        }
        if(input.categoryId()!=null) {
            categoryRepository.findById(input.categoryId()).ifPresent(catFound -> p.setCategory(catFound));
        }
        return productRepository.save(p);
    }

    @MutationMapping
    public Product updateProduct(@Argument Long id, @Argument ProductInput input){
        return productRepository.findById(id).map(p -> {
            if(input.title()!=null) p.setTitle(input.title());
            if(input.quantity()!=null) p.setQuantity(input.quantity());
            if(input.desc()!=null) p.setDesc(input.desc());
            if(input.price()!=null) p.setPrice(input.price());
            if(input.userId()!=null) userRepository.findById(input.userId()).ifPresent(userFound -> p.setUser(userFound));
            if(input.categoryId()!=null) categoryRepository.findById(input.categoryId()).ifPresent(catFound -> p.setCategory(catFound));
            return productRepository.save(p);
        }).orElse(null);
    }

    @MutationMapping
    public Boolean deleteProduct(@Argument Long id){
        if(!productRepository.existsById(id)) return false;
        productRepository.deleteById(id);return true;
    }

    /* =========== Update user categories (many-to-many) =========== */
    @MutationMapping
    public User updateUserCategories(@Argument Long userId, @Argument List<Long> categoryIds){
        return userRepository.findById(userId).map(u -> {
            Set<Category> newCats = new HashSet<>(categoryRepository.findAllById(categoryIds));
            u.setCategories(newCats);
            return userRepository.save(u);
        }).orElse(null);
    }
}