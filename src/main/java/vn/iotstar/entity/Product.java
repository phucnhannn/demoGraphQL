package vn.iotstar.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "products")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
@ToString
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private Integer quantity;
    @Column(name = "description", length = 2000)
    private String desc; // renamed physical column to 'description' to avoid reserved keyword 'desc'
    private Double price;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    @ToString.Exclude
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    @ToString.Exclude
    private Category category;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public String getDesc() { return desc; }
    public void setDesc(String desc) { this.desc = desc; }
    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    /* Manual builder (optional) */
    public static ProductBuilder builder(){ return new ProductBuilder(); }
    public static class ProductBuilder {
        private String title; private Integer quantity; private String desc; private Double price; private User user; private Category category;
        public ProductBuilder title(String title){ this.title=title; return this; }
        public ProductBuilder quantity(Integer quantity){ this.quantity=quantity; return this; }
        public ProductBuilder desc(String desc){ this.desc=desc; return this; }
        public ProductBuilder price(Double price){ this.price=price; return this; }
        public ProductBuilder user(User user){ this.user=user; return this; }
        public ProductBuilder category(Category category){ this.category=category; return this; }
        public Product build(){ Product p=new Product(); p.title=title; p.quantity=quantity; p.desc=desc; p.price=price; p.user=user; p.category=category; return p; }
    }
}