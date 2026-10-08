package demo.model;

import java.util.Collections;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

/**
 * A node in the catalogue tree. Roots (parent == null) are the product
 * ranges; every other node is a child category of arbitrary depth.
 *
 * The tree drives navigation and catalogue grouping. Categories can also show
 * introductions, applications, technical specs and documents directly on the
 * catalogue page; they do not have separate detail pages.
 */
@Entity
@Table(name = "category")
public class Category {

    private static final ObjectMapper mapper = new ObjectMapper();

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private Category parent;

    @OneToMany(mappedBy = "parent")
    @OrderBy("sortOrder, id")
    private List<Category> children = new ArrayList<>();

    /** Products filed directly here. Branch categories normally have none. */
    @ManyToMany(mappedBy = "categories")
    @OrderBy("id")
    private List<Product> products = new ArrayList<>();

    @Column(columnDefinition = "varchar(120)")
    private String slug;

    @Column(columnDefinition = "varchar(200)")
    private String name;

    @Column(name = "sort_order")
    private int sortOrder;

    @Column(columnDefinition = "text")
    private String description;

    @Column(columnDefinition = "text")
    private String applications;

    @Column(columnDefinition = "text")
    private String specs;

    @Column(columnDefinition = "text")
    private String documents;

    @Column(name = "image_path", columnDefinition = "varchar(255)")
    private String imagePath;

    @Column(nullable = false)
    private boolean visible = true;

    // ── Transient helpers ────────────────────────────────────────────────────

    @Transient
    public boolean isLeaf() {
        return children == null || children.isEmpty();
    }

    /** Root-to-here chain, used to render breadcrumbs from real parentage. */
    @Transient
    public List<Category> getAncestors() {
        List<Category> chain = new ArrayList<>();
        for (Category c = parent; c != null; c = c.getParent()) {
            chain.add(0, c);
        }
        return chain;
    }

    // ── Getters & Setters ────────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Category getParent() { return parent; }
    public void setParent(Category parent) { this.parent = parent; }

    public List<Category> getChildren() { return children; }
    public void setChildren(List<Category> children) { this.children = children; }
    @Transient
    public List<Category> getVisibleChildren() {
        return children.stream().filter(Category::isVisible).toList();
    }
    @Transient
    public List<Category> getVisibleProductChildren() {
        return getVisibleChildren().stream()
            .filter(child -> !child.getVisibleProducts().isEmpty()).toList();
    }
    @Transient
    public List<Category> getVisibleGroupChildren() {
        return getVisibleChildren().stream()
            .filter(child -> child.getVisibleProducts().isEmpty()).toList();
    }

    public List<Product> getProducts() { return products; }
    public void setProducts(List<Product> products) { this.products = products; }
    @Transient
    public List<Product> getVisibleProducts() {
        return products.stream().filter(Product::isVisible).toList();
    }

    @Transient
    public List<String> getApplicationsList() {
        if (applications == null || applications.isBlank()) return Collections.emptyList();
        try { return mapper.readValue(applications, new TypeReference<List<String>>() {}); }
        catch (Exception e) { return Collections.emptyList(); }
    }

    @Transient
    public List<Product.SpecEntry> getSpecsList() {
        if (specs == null || specs.isBlank()) return Collections.emptyList();
        try { return mapper.readValue(specs, new TypeReference<List<Product.SpecEntry>>() {}); }
        catch (Exception e) { return Collections.emptyList(); }
    }

    @Transient
    public List<Product.DocEntry> getDocumentsList() {
        if (documents == null || documents.isBlank()) return Collections.emptyList();
        try { return mapper.readValue(documents, new TypeReference<List<Product.DocEntry>>() {}); }
        catch (Exception e) { return Collections.emptyList(); }
    }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getApplications() { return applications; }
    public void setApplications(String applications) { this.applications = applications; }
    public String getSpecs() { return specs; }
    public void setSpecs(String specs) { this.specs = specs; }
    public String getDocuments() { return documents; }
    public void setDocuments(String documents) { this.documents = documents; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public boolean isVisible() { return visible; }
    public void setVisible(boolean visible) { this.visible = visible; }
}
