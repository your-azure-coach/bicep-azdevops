using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace DocumentApp.Api.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class DocumentController : ControllerBase
    {
        private readonly BlobContainerClient _blobContainerClient;
        private readonly ILogger<DocumentController> _logger;
        private readonly IConfiguration _config;
        private readonly Random _random;

        public DocumentController(ILogger<DocumentController> logger, IConfiguration configuration, BlobServiceClient blobServiceClient)
        {
            _blobContainerClient = blobServiceClient.GetBlobContainerClient(configuration.GetValue<string>("BLOB_CONTAINER_NAME", "documents"));
            _blobContainerClient.CreateIfNotExists();
            _logger = logger;
            _config = configuration;
            _random = new Random();
        }

        [HttpPost]
        public async Task<IActionResult> UploadDocument()
        {
            int processingDelay = _random.Next(0, _config.GetValue<int>("DOCUMENT_MAX_PROCESSING_DELAY", 0));
            Thread.Sleep(processingDelay * 1000);

            var blob = _blobContainerClient.GetBlobClient(Guid.NewGuid().ToString());
            using (var ms = new MemoryStream(2048))
            {
                await Request.Body.CopyToAsync(ms);
                await blob.UploadAsync(new BinaryData(ms.ToArray()));
            }

            var response = JsonDocument.Parse("{\"id\": \"" + blob.Name + "\", \"message\": \"" + _config.GetValue<string>("DOCUMENT_RESPONSE_MESSAGE", "Thank you very much for your document!") + "\"}");
            return Ok(response);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> DownloadDocument(string id)
        {
            var blob = _blobContainerClient.GetBlobClient(id);
            if (await blob.ExistsAsync())
            {
                var document = await blob.DownloadAsync();
                return File(document.Value.Content, document.Value.ContentType, id);
            }
            return BadRequest();
        }
    }
}