package demo.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.Test;

import demo.model.Category;
import demo.repository.CategoryRepository;

/** Structure comes from parent_id — these tests pin that, not name parsing. */
class CategoryServiceTest {

    private final CategoryRepository repository = mock(CategoryRepository.class);
    private final CategoryService service = new CategoryService(repository);

    private static Category category(String slug, String name, Category parent) {
        Category c = new Category();
        c.setSlug(slug);
        c.setName(name);
        c.setParent(parent);
        if (parent != null) parent.getChildren().add(c);
        return c;
    }

    @Test
    void getRoots_returnsRepositoryOrder() {
        Category acv = category("automatic-control-valve", "Automatic Control Valve", null);
        Category hvac = category("control-valve-hvac", "Control valve HVAC", null);
        when(repository.findRoots()).thenReturn(List.of(acv, hvac));

        List<Category> roots = service.getRoots();

        assertEquals(2, roots.size());
        assertEquals("automatic-control-valve", roots.get(0).getSlug());
        assertEquals("control-valve-hvac", roots.get(1).getSlug());
    }

    /** Product-detail breadcrumbs render this chain. */
    @Test
    void ancestors_areBuiltFromTheParentChain() {
        Category acv      = category("automatic-control-valve", "Automatic Control Valve", null);
        Category pilot    = category("pilot-operated-control-valves", "Pilot Operated Control Valves", acv);
        Category series   = category("pressure-control-series", "1. Pressure Control Series", pilot);
        Category reducing = category("pressure-reducing-series", "1.1 Pressure Reducing Series", series);

        assertEquals(List.of("Automatic Control Valve",
                             "Pilot Operated Control Valves",
                             "1. Pressure Control Series"),
                     reducing.getAncestors().stream().map(Category::getName).toList());
        assertTrue(acv.getAncestors().isEmpty());
    }

    @Test
    void leaf_isDrivenByChildren() {
        Category acv = category("automatic-control-valve", "Automatic Control Valve", null);
        Category anti = category("anti-water-hammer-valves", "Anti Water Hammer Valves", acv);

        assertFalse(acv.isLeaf());
        assertTrue(anti.isLeaf());
    }
}
