package demo.config;

import java.util.Collections;
import java.util.List;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import demo.model.Category;
import demo.service.CategoryService;
import jakarta.servlet.http.HttpServletRequest;

@ControllerAdvice
public class GlobalModelAttributes {

    private final CategoryService categoryService;

    public GlobalModelAttributes(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @ModelAttribute("currentUri")
    public String currentUri(HttpServletRequest request) {
        return request.getRequestURI();
    }

    /**
     * Root-relative canonical. GBSE has no confirmed domain yet, so no host is
     * prefixed — browsers and crawlers resolve this against the page URL.
     * TODO: return "https://<official-domain>" + request.getRequestURI() once the
     * domain is registered; absolute canonicals are the SEO-preferred form.
     */
    @ModelAttribute("canonicalUrl")
    public String canonicalUrl(HttpServletRequest request) {
        return request.getRequestURI();
    }

    @ModelAttribute("ogDescription")
    public String ogDescription() {
        return "GBSE – Equipment and solutions for HVAC, water supply and fire fighting systems.";
    }

    /** Category tree for the mega menu — categories only, never products. */
    @ModelAttribute("navCategories")
    public List<Category> navCategories() {
        try {
            return categoryService.getRoots();
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }
}
