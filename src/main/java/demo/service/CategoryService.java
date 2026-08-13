package demo.service;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import demo.model.Category;
import demo.repository.CategoryRepository;

/** Reads the catalogue tree. Structure comes from parent_id, never from names. */
@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    /** The ranges, each with its subtree populated — drives the mega menu. */
    @Cacheable("categories")
    @Transactional(readOnly = true)
    public List<Category> getRoots() {
        List<Category> roots = categoryRepository.findRoots();
        roots.forEach(CategoryService::touchTree);
        return roots;
    }

    /**
     * Forces the lazy collections the templates walk, while the session is
     * still open. The table is small, so loading the whole subtree costs less
     * than the round trips a per-node lookup would make.
     */
    private static void touchTree(Category category) {
        category.getProducts().size();
        category.getChildren().forEach(CategoryService::touchTree);
    }
}
