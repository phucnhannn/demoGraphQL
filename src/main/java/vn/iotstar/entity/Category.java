package vn.iotstar.entity;

import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.AllArgsConstructor;
import lombok.ToString;

@Entity
@Table(name = "categories")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString
public class Category {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String images;

    @ManyToMany(mappedBy = "categories")
    @ToString.Exclude
    private Set<User> users = new HashSet<>();

    @OneToMany(mappedBy = "category", cascade = CascadeType.ALL, orphanRemoval = true)
    @ToString.Exclude
    private Set<Product> products = new HashSet<>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getImages() {
        return images;
    }

    public void setImages(String images) {
        this.images = images;
    }

    public Set<User> getUsers() {
        return users;
    }

    public void setUsers(Set<User> users) {
        this.users = users;
    }

    public Set<Product> getProducts() {
        return products;
    }

    public void setProducts(Set<Product> products) {
        this.products = products;
    }

    /* Manual builder */
    public static CategoryBuilder builder() {
        return new CategoryBuilder();
    }

    public static class CategoryBuilder {
        private String name;
        private String images;
        private Set<User> users = new java.util.HashSet<>();
        private Set<Product> products = new java.util.HashSet<>();

        public CategoryBuilder name(String name) {
            this.name = name;
            return this;
        }

        public CategoryBuilder images(String images) {
            this.images = images;
            return this;
        }

        public CategoryBuilder users(Set<User> users) {
            this.users = users;
            return this;
        }

        public CategoryBuilder products(Set<Product> products) {
            this.products = products;
            return this;
        }

        public Category build() {
            Category c = new Category();
            c.name = this.name;
            c.images = this.images;
            c.users = this.users;
            c.products = this.products;
            return c;
        }
    }
}