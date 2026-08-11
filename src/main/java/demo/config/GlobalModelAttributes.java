package demo.config;

import java.util.Collections;
import java.util.List;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import demo.model.RangeGroup;
import demo.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;

@ControllerAdvice
public class GlobalModelAttributes {

    private final ProductService productService;

    public GlobalModelAttributes(ProductService productService) {
        this.productService = productService;
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

    @ModelAttribute("navRanges")
    public List<RangeGroup> navRanges() {
        try {
            return productService.getRangeGroups(productService.findAll());
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }
}
