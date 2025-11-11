using Microsoft.AspNetCore.Mvc;
using PipelinePilot.Models;

namespace PipelinePilot.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UsersController : ControllerBase
    {
        private static readonly List<User> Users = new()
        {
            new User { Id = 1, Name = "John Doe", Email = "john.doe@example.com", Department = "Engineering", JoinedDate = new DateTime(2020, 3, 15), IsActive = true },
            new User { Id = 2, Name = "Jane Smith", Email = "jane.smith@example.com", Department = "Marketing", JoinedDate = new DateTime(2019, 7, 22), IsActive = true },
            new User { Id = 3, Name = "Bob Johnson", Email = "bob.johnson@example.com", Department = "Sales", JoinedDate = new DateTime(2021, 1, 10), IsActive = true },
            new User { Id = 4, Name = "Alice Williams", Email = "alice.williams@example.com", Department = "Engineering", JoinedDate = new DateTime(2022, 5, 8), IsActive = true },
            new User { Id = 5, Name = "Charlie Brown", Email = "charlie.brown@example.com", Department = "HR", JoinedDate = new DateTime(2018, 11, 3), IsActive = false }
        };

        private readonly ILogger<UsersController> _logger;

        public UsersController(ILogger<UsersController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetAllUsers")]
        public IEnumerable<User> Get()
        {
            _logger.LogInformation("Getting all users");
            return Users;
        }

        [HttpGet("{id}", Name = "GetUserById")]
        public ActionResult<User> GetById(int id)
        {
            var user = Users.FirstOrDefault(u => u.Id == id);
            if (user == null)
            {
                return NotFound(new { message = $"User with ID {id} not found" });
            }
            return user;
        }

        [HttpGet("department/{department}", Name = "GetUsersByDepartment")]
        public IEnumerable<User> GetByDepartment(string department)
        {
            return Users.Where(u => u.Department.Equals(department, StringComparison.OrdinalIgnoreCase));
        }

        [HttpGet("active", Name = "GetActiveUsers")]
        public IEnumerable<User> GetActive()
        {
            return Users.Where(u => u.IsActive);
        }
    }
}
