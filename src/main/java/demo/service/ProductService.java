package demo.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.annotation.Lazy;
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
    private ProductService self;
    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }
     @Autowired
    public void setSelf(@Lazy ProductService self) {
        this.self = self;
    }

    @Cacheable("products")
    @Transactional(readOnly = true)
    public List<Product> findAll() {
        return productRepository.findAll(Sort.by("id").ascending());
    }

    @Transactional(readOnly = true)
    public List<ProductSearchItem> findAllForSearch() {
        // 3. Sửa findAll() thành self.findAll() để đi qua Proxy
        return self.findAll().stream()
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
