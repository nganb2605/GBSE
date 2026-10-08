package demo.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import demo.dto.ContactFormDto;
import demo.model.Product;
import demo.model.ContactRequest;
import demo.service.CategoryService;
import demo.service.ContactRateLimiter;
import demo.service.ContactRequestService;
import demo.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;

@Controller
public class PublicController {

    private final ProductService productService;
    private final CategoryService categoryService;
    private final ContactRequestService contactRequestService;
    private final ContactRateLimiter contactRateLimiter;

    public PublicController(ProductService productService,
                            CategoryService categoryService,
                            ContactRequestService contactRequestService,
                            ContactRateLimiter contactRateLimiter) {
        this.productService = productService;
        this.categoryService = categoryService;
        this.contactRequestService = contactRequestService;
        this.contactRateLimiter = contactRateLimiter;
    }

    @GetMapping("/")
    public String home() { return "home"; }

    @GetMapping("/about")
    public String about() { return "about"; }

    @GetMapping("/projects")
    public String projects() { return "projects"; }

    @GetMapping("/news")
    public String news() { return "news"; }

    @GetMapping({"/products", "/products/"})
    public String products(Model model) {
        model.addAttribute("roots", categoryService.getRoots());
        model.addAttribute("allProducts", productService.findAllForSearch());
        return "products";
    }

    @GetMapping(value = "/sitemap.xml", produces = MediaType.APPLICATION_XML_VALUE)
    @ResponseBody
    public String sitemap() {
        String base = ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString();
        StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
            .append("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">");
        for (String path : new String[] {"/", "/about", "/products", "/projects", "/news", "/contact"}) {
            xml.append("<url><loc>").append(base).append(path).append("</loc></url>");
        }
        productService.findAll().forEach(p -> xml.append("<url><loc>")
            .append(base).append("/products/").append(p.getId()).append("</loc></url>"));
        return xml.append("</urlset>").toString();
    }

    @GetMapping("/products/{id}")
    public String productDetail(@PathVariable Long id, Model model) {
        Product product = productService.findById(id).orElse(null);
        if (product == null) return "redirect:/products";
        model.addAttribute("product", product);
        String desc = (product.getDescription() != null && !product.getDescription().isBlank())
                ? product.getDescription()
                : (product.getShortText() != null && !product.getShortText().isBlank())
                        ? product.getShortText()
                        : "GBSE – Equipment and solutions for HVAC, water supply and fire fighting systems.";
        model.addAttribute("ogDescription", desc);
        return "product-detail";
    }

    @GetMapping("/contact")
    public String contact(Model model) {
        model.addAttribute("contactForm", new ContactFormDto());
        return "contact";
    }

    @PostMapping("/contact")
    public String submitContact(@ModelAttribute("contactForm") ContactFormDto form,
                                @RequestParam(name = "website", required = false) String honeypot,
                                HttpServletRequest request,
                                Model model) {
        if (honeypot != null && !honeypot.isBlank()) {
            model.addAttribute("success", true);
            model.addAttribute("contactForm", new ContactFormDto());
            return "contact";
        }

        if (!contactRateLimiter.isAllowed(request.getRemoteAddr())) {
            model.addAttribute("rateLimitError", true);
            model.addAttribute("contactForm", form);
            return "contact";
        }

        ContactRequest contactRequest = new ContactRequest();
        contactRequest.setFullName(form.getFullName());
        contactRequest.setPhone(form.getPhone());
        contactRequest.setEmail(form.getEmail());
        contactRequest.setMessage(form.getMessage());

        contactRequestService.save(contactRequest);

        model.addAttribute("success", true);
        model.addAttribute("contactForm", new ContactFormDto());
        return "contact";
    }

    @GetMapping("/login")
    public String login() { return "login"; }

    @GetMapping("/access-denied")
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public String accessDenied() { return "error/403"; }
}
