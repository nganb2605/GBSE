package demo.repository;

import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import demo.model.Category;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    /**
     * Every root in display order. Children are walked from the entity graph;
     * the whole table is small enough that one fetch populates the tree.
     */
    @EntityGraph(attributePaths = "children")
    @Query("SELECT c FROM Category c WHERE c.parent IS NULL ORDER BY c.sortOrder, c.id")
    List<Category> findRoots();
}
