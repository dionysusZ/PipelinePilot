using Microsoft.AspNetCore.Mvc.Testing;
using System.Net;
using System.Net.Http.Json;
using Xunit;

namespace PipelinePilot.Tests
{
    public class MathControllerTests : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly WebApplicationFactory<Program> _factory;
        private readonly HttpClient _client;

        public MathControllerTests(WebApplicationFactory<Program> factory)
        {
            _factory = factory;
            _client = _factory.CreateClient();
        }

        [Theory]
        [InlineData(2, 3, 5)]
        [InlineData(0, 0, 0)]
        [InlineData(-5, 5, 0)]
        [InlineData(10.5, 20.3, 30.8)]
        [InlineData(-10, -20, -30)]
        public async Task Sum_ReturnsCorrectResult(double a, double b, double expected)
        {
            // Act
            var response = await _client.GetAsync($"/Math/sum?a={a}&b={b}");

            // Assert
            response.EnsureSuccessStatusCode();
            var result = await response.Content.ReadFromJsonAsync<double>();
            Assert.Equal(expected, result, precision: 10);
        }

        [Fact]
        public async Task Sum_ReturnsOkStatus()
        {
            // Act
            var response = await _client.GetAsync("/Math/sum?a=5&b=10");

            // Assert
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }
    }
}
