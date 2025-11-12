using Microsoft.AspNetCore.Mvc;

namespace PipelinePilot.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NameController : ControllerBase
    {
        [HttpGet]
        public string Get()
        {
            return "Vusal";
        }
    }
}
