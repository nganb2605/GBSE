package demo.service;

import java.util.List;

import org.hibernate.Hibernate;
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

    /** Navigation needs the category hierarchy, not the product catalogue. */
    @Cacheable("navigationCategories")
    @Transactional(readOnly = true)
    public List<Category> getNavigationRoots() {
        List<Category> roots = categoryRepository.findRoots();
        roots.forEach(CategoryService::touchChildren);
        return roots;
    }

    private static void touchChildren(Category category) {
        category.getChildren().forEach(CategoryService::touchChildren);
    }

    /** The ranges, each with its subtree populated — drives the mega menu. */
    @Cacheable("categories")
    @Transactional(readOnly = true)
    public List<Category> getRoots() {
        List<Category> roots = categoryRepository.findRoots();
        roots.forEach(CategoryService::touchTree);
        return roots;
    }


    private static void touchTree(Category category) {
        // 2. Sửa dòng gọi .size() thành Hibernate.initialize()
        Hibernate.initialize(category.getProducts());
        
        category.getChildren().forEach(CategoryService::touchTree);
    }
}
