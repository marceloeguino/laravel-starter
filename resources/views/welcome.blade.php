<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>DevOps Challenge - Laravel</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700" rel="stylesheet" />

        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Inter', sans-serif;
                line-height: 1.6;
                color: #333;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                padding: 2rem;
            }

            .container {
                max-width: 800px;
                margin: 0 auto;
                background: white;
                border-radius: 12px;
                box-shadow: 0 20px 40px rgba(0,0,0,0.1);
                overflow: hidden;
            }

            .header {
                background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
                color: white;
                padding: 2rem;
                text-align: center;
            }

            .header h1 {
                font-size: 2rem;
                font-weight: 700;
                margin-bottom: 0.5rem;
            }

            .content {
                padding: 2rem;
            }

            .section {
                margin-bottom: 2rem;
            }

            .section h2 {
                color: #2c3e50;
                font-size: 1.5rem;
                font-weight: 600;
                margin-bottom: 1rem;
                border-bottom: 2px solid #3498db;
                padding-bottom: 0.5rem;
            }

            .section p {
                margin-bottom: 1rem;
                font-size: 1.1rem;
            }

            .highlight {
                background: #f8f9fa;
                border-left: 4px solid #3498db;
                padding: 1rem;
                margin: 1rem 0;
                border-radius: 4px;
            }

            .meta-info {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1rem;
                margin: 1rem 0;
            }

            .meta-item {
                background: #ecf0f1;
                padding: 1rem;
                border-radius: 6px;
                text-align: center;
            }

            .meta-item strong {
                display: block;
                color: #2c3e50;
                font-weight: 600;
                margin-bottom: 0.5rem;
            }

            .pipeline {
                background: #e8f4fd;
                border: 1px solid #3498db;
                border-radius: 6px;
                padding: 1rem;
                text-align: center;
                font-family: 'Courier New', monospace;
                font-weight: 600;
                color: #2c3e50;
                margin: 1rem 0;
            }

            @media (max-width: 768px) {
                body {
                    padding: 1rem;
                }
                
                .header h1 {
                    font-size: 1.5rem;
                }
                
                .meta-info {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>DevOps Challenge</h1>
                <p>Laravel → Docker → Jenkins → DigitalOcean (No Compose)</p>
            </div>
            
            <div class="content">
                <div class="section">
                    <h2>Overview</h2>
                    <p>Containerize a Laravel API, build and publish its image via <strong>Jenkins</strong>, and deploy it as a single Docker container on <strong>DigitalOcean</strong>. The deployed service should expose a health endpoint that shows build metadata.</p>
                    
                    <div class="meta-info">
                        <div class="meta-item">
                            <strong>Timebox</strong>
                            4–6 hours (1–2 days)
                        </div>
                        <div class="meta-item">
                            <strong>Difficulty</strong>
                            Intermediate–Senior DevOps
                        </div>
                    </div>
                </div>

                <div class="section">
                    <h2>Scenario</h2>
                    <p>You join a team managing a small Laravel service and need a repeatable, automated delivery pipeline. Security of secrets and clear documentation are critical.</p>
                    
                    <div class="pipeline">
                        code → Docker image → deployed service
                    </div>
                </div>

                <div class="highlight">
                    <strong>Key Requirements:</strong>
                    <ul style="margin-top: 0.5rem; padding-left: 1.5rem;">
                        <li>Containerized Laravel API</li>
                        <li>Jenkins CI/CD pipeline</li>
                        <li>Single Docker container deployment</li>
                        <li>Health endpoint with build metadata</li>
                        <li>Secure secret management</li>
                        <li>Comprehensive documentation</li>
                    </ul>
                </div>
            </div>
        </div>
    </body>
</html>
