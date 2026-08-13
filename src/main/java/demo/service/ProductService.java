package demo.service;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import demo.dto.ProductSearchItem;
import demo.model.Category;
import demo.model.Product;
import demo.repository.ProductRepository;

@Service
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Cacheable("products")
    @Transactional(readOnly = true)
    public List<Product> findAll() {
        return productRepository.findAll(Sort.by("id").ascending());
    }

    /**
     * Flat list for the catalogue page's client-side search box. Entities are
     * not inlined into the page directly — they now reach into the category
     * tree, which Jackson cannot serialise without cycling parent/children.
     */
    @Transactional(readOnly = true)
    public List<ProductSearchItem> findAllForSearch() {
        return findAll().stream()
            .map(p -> new ProductSearchItem(p.getId(), p.getName(), p.getShortText(), p.getImage()))
            .toList();
    }

    @Transactional(readOnly = true)
    public Optional<Product> findById(Long id) {
        Optional<Product> product = productRepository.findById(id);
        // Breadcrumbs walk the placement chain while the view renders.
        product.ifPresent(p -> p.getCategories().forEach(c -> {
            for (Category a = c.getParent(); a != null; a = a.getParent()) a.getName();
        }));
        return product;
    }
}
