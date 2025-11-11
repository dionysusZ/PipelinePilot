using Microsoft.AspNetCore.Mvc;
using PipelinePilot.Models;

namespace PipelinePilot.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProductsController : ControllerBase
    {
        private static readonly List<Product> Products = new()
        {
            new Product { Id = 1, Name = "Laptop", Description = "High-performance laptop", Price = 1299.99m, Stock = 15, Category = "Electronics" },
            new Product { Id = 2, Name = "Smartphone", Description = "Latest model smartphone", Price = 899.99m, Stock = 25, Category = "Electronics" },
            new Product { Id = 3, Name = "Headphones", Description = "Noise-cancelling headphones", Price = 249.99m, Stock = 50, Category = "Audio" },
            new Product { Id = 4, Name = "Keyboard", Description = "Mechanical gaming keyboard", Price = 129.99m, Stock = 30, Category = "Accessories" },
            new Product { Id = 5, Name = "Mouse", Description = "Wireless ergonomic mouse", Price = 49.99m, Stock = 100, Category = "Accessories" }
        };

        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ILogger<ProductsController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetAllProducts")]
        public IEnumerable<Product> Get()
        {
            _logger.LogInformation("Getting all products");
            return Products;
        }

        [HttpGet("{id}", Name = "GetProductById")]
        public ActionResult<Product> GetById(int id)
        {
            var product = Products.FirstOrDefault(p => p.Id == id);
            if (product == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }
            return product;
        }

        [HttpGet("category/{category}", Name = "GetProductsByCategory")]
        public IEnumerable<Product> GetByCategory(string category)
        {
            return Products.Where(p => p.Category.Equals(category, StringComparison.OrdinalIgnoreCase));
        }

        [HttpGet("search", Name = "SearchProducts")]
        public IEnumerable<Product> Search([FromQuery] string? query)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return Products;
            }

            return Products.Where(p =>
                p.Name.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                p.Description.Contains(query, StringComparison.OrdinalIgnoreCase)
            );
        }
    }
}
