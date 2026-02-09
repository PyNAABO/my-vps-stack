# IT-Tools

**Status:** Archived (Disabled) - Move out of `.archive/` to re-enable

## Overview

IT-Tools is a comprehensive collection of handy online tools for developers, system administrators, and IT professionals. It provides a clean, modern interface for common development and system administration tasks.

## Features

- **50+ Developer Tools** - Everything from format converters to encoders
- **No External Dependencies** - All tools work offline once loaded
- **Privacy Focused** - No data leaves your server
- **Modern UI** - Clean, responsive interface with dark mode support
- **Open Source** - Free to use and self-host

## Included Tools

### Development Tools
- **JSON Formatter** - Format and validate JSON
- **SQL Formatter** - Beautify SQL queries
- **JWT Parser** - Decode and verify JWT tokens
- **Base64 Encoder/Decoder** - Convert to/from Base64
- **URL Encoder/Decoder** - Encode and decode URLs
- **HTML Encoder/Decoder** - Escape and unescape HTML entities

### Security Tools
- **Password Generator** - Create secure random passwords
- **Hash Generator** - Generate MD5, SHA1, SHA256 hashes
- **UUID Generator** - Generate random UUIDs
- **Token Generator** - Create secure tokens
- **Bcrypt Generator** - Hash passwords with bcrypt

### System Tools
- **Cron Expression Parser** - Human-readable cron explanations
- **Docker Compose Converter** - Convert between formats
- **Unit Converter** - Convert between various units
- **Date Converter** - Convert between timestamp formats

### Data Tools
- **CSV to JSON** - Convert CSV files to JSON
- **YAML to JSON** - Convert between YAML and JSON
- **XML Formatter** - Format and validate XML
- **Regex Tester** - Test regular expressions

## Access

- **Subdomain:** `tools.*`
- **Port:** 8082
- **URL:** `https://tools.YOURDOMAIN.com`

## Configuration

### Docker Compose

```yaml
services:
  it-tools:
    image: corentinth/it-tools:latest
    container_name: it-tools
    restart: always
    ports:
      - "8082:80"
```

### Environment Variables

IT-Tools runs with zero configuration required. No environment variables needed!

## Use Cases

- **Quick Conversions** - Convert data formats on the fly
- **Security Tasks** - Generate passwords, hashes, tokens
- **Development** - Format code, test regex, parse JSON
- **System Admin** - Work with cron, Docker, various encodings
- **Offline Access** - All tools work without internet

## First Time Setup

1. Navigate to `https://tools.YOURDOMAIN.com`
2. No authentication required
3. Browse tools by category or use the search bar
4. Bookmark frequently used tools

## Tips

- **Search:** Use the search bar to quickly find tools
- **Favorites:** Star your most-used tools for quick access
- **Copy:** Most tools have one-click copy buttons for results
- **History:** Some tools maintain a history of recent conversions
- **Mobile Friendly:** Works great on phones and tablets

## Comparison with Online Tools

| Feature | IT-Tools (Self-Hosted) | Online Tools |
|---------|------------------------|--------------|
| Privacy | Data stays on your server | Sent to third-party |
| Availability | Works offline | Requires internet |
| Speed | Instant | Network dependent |
| Cost | Free | Often ad-supported |
| Security | Full control | Trust third-party |

## Links

- [GitHub Repository](https://github.com/CorentinTh/it-tools)
- [Live Demo](https://it-tools.tech)
