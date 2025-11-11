using Microsoft.AspNetCore.Mvc;

namespace PipelinePilot.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MathController : ControllerBase
    {
        private readonly ILogger<MathController> _logger;

        public MathController(ILogger<MathController> logger)
        {
            _logger = logger;
        }

        [HttpGet("sum")]
        public ActionResult<double> Sum([FromQuery] double a, [FromQuery] double b)
        {
            _logger.LogInformation("Sum operation called with a={A} and b={B}", a, b);
            var result = a + b;
            return Ok(result);
        }
    }
}
