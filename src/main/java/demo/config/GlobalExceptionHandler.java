package demo.config;

  import org.slf4j.Logger;
  import org.slf4j.LoggerFactory;
  import org.springframework.http.HttpStatus;
  import org.springframework.web.servlet.ModelAndView;
  import org.springframework.web.util.DisconnectedClientHelper;
  import jakarta.servlet.http.HttpServletResponse;
  import org.springframework.web.bind.annotation.ControllerAdvice;
  import org.springframework.web.bind.annotation.ExceptionHandler;
  import org.springframework.web.servlet.resource.NoResourceFoundException;

  @ControllerAdvice
  public class GlobalExceptionHandler {

      private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
      private static final DisconnectedClientHelper disconnectedClient =
          new DisconnectedClientHelper(GlobalExceptionHandler.class.getName());

      @ExceptionHandler(NoResourceFoundException.class)
      public ModelAndView handle404() {
          return new ModelAndView("error/404", HttpStatus.NOT_FOUND);
      }

      @ExceptionHandler(Exception.class)
      public ModelAndView handle500(Exception e, HttpServletResponse response) {
          // Cancelled downloads have no client to render an error page for.
          if (disconnectedClient.checkAndLogClientDisconnectedException(e)) {
              return new ModelAndView();
          }
          log.error("Unhandled exception", e);
          // An already-sent response cannot be replaced by an HTML error page.
          if (response.isCommitted()) {
              return new ModelAndView();
          }
          return new ModelAndView("error/500", HttpStatus.INTERNAL_SERVER_ERROR);
      }
  }
