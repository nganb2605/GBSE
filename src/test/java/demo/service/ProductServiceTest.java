package demo.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.data.domain.Sort;

import demo.dto.ProductSearchItem;
import demo.model.Category;
import demo.model.Product;
import demo.repository.ProductRepository;

/** Unit tests for product retrieval — no Spring context needed. */
class ProductServiceTest {

    private final ProductRepository repository = mock(ProductRepository.class);
    private final ProductService service = new ProductService(repository);

    private static Product product(String name, Category... categories) {
        Product p = new Product();
        p.setName(name);
        p.setShortText(name + " blurb");
        p.setCategories(List.of(categories));
        return p;
    }

    private static Category category(String slug, String name) {
        Category c = new Category();
        c.setSlug(slug);
        c.setName(name);
        return c;
    }

    @Test
    void findAllForSearch_exposesOnlyTheFieldsTheSearchBoxNeeds() {
        when(repository.findAll(any(Sort.class)))
            .thenReturn(List.of(product("N300 - Check Valve", category("pump-station-check-valve", "5."))));

        List<ProductSearchItem> items = service.findAllForSearch();

        assertEquals(1, items.size());
        assertEquals("N300 - Check Valve", items.get(0).name());
        assertEquals("N300 - Check Valve blurb", items.get(0).shortText());
        // No image set, so the shared placeholder stands in.
        assertEquals("/images/placeholder.png", items.get(0).image());
    }

    @Test
    void primaryCategory_isTheFirstPlacement() {
        Category anti = category("anti-water-hammer-valves", "Anti Water Hammer Valves");
        Category over = category("overpressure-protection", "1.2 Overpressure Protection");
        Product n550 = product("N550 - Surge Anticipation Valve", anti, over);

        assertEquals(2, n550.getCategories().size());
        assertEquals("anti-water-hammer-valves", n550.getPrimaryCategory().getSlug());
    }

    @Test
    void primaryCategory_isNullWhenUnfiled() {
        assertNull(product("Orphan").getPrimaryCategory());
    }

    @Test
    void descriptionLines_areOnePointPerLine() {
        Product p = new Product();
        p.setDescription("First point.\nSecond point.\n\n  Third point.  ");
        assertEquals(List.of("First point.", "Second point.", "Third point."), p.getDescriptionLines());

        p.setDescription("Only one sentence.");
        assertEquals(List.of("Only one sentence."), p.getDescriptionLines());

        p.setDescription(null);
        assertTrue(p.getDescriptionLines().isEmpty());
    }

    @Test
    void findById_delegatesToRepository() {
        when(repository.findById(1L)).thenReturn(Optional.of(product("DN15-32")));
        assertTrue(service.findById(1L).isPresent());
    }
}
