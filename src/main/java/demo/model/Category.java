package demo.model;

import java.util.ArrayList;
import java.util.List;

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
 * The tree is navigation only — it drives the mega menu and the grouping on
 * the catalogue page. A category has no page of its own, so it carries no
 * editorial content; the description/specs/documents columns V16 added are
 * empty and unmapped (see V17).
 */
@Entity
@Table(name = "category")
public class Category {

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

    public List<Product> getProducts() { return products; }
    public void setProducts(List<Product> products) { this.products = products; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
}
