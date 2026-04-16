import sys
import json
from curl_cffi import requests

# Configuration
DEFAULT_LANG = "Portuguese"
FALLBACK_LANG = "English"

def fetch_comick(query, media_type="manga"):
    """Fetch data from Comick.io"""
    try:
        # Comick search API
        url = f"https://api.comick.io/v1.0/search?q={query}&type={media_type}"
        response = requests.get(url, impersonate="chrome110")

        if response.status_code == 200:
            data = response.json()
            results = []
            for item in data.get('results', []):
                results.append({
                    "id": item.get('id'),
                    "title": item.get('title'),
                    "cover_url": f"https://meo.comick.io/covers/{item.get('id')}.jpg",
                    "source": "Comick",
                    "type": media_type
                })
            return results
        return []
    except Exception as e:
        print(f"Comick error: {e}")
        return []

def fetch_mangadex(query, media_type="manga"):
    """Fetch data from MangaDex as fallback"""
    try:
        # MangaDex API
        url = f"https://api.mangadex.org/manga?title={query}&limit=10"
        response = requests.get(url, impersonate="chrome110")

        if response.status_code == 200:
            data = response.json()
            results = []
            for item in data.get('data', []):
                # MangaDex cover URLs are complex, simplified here
                cover_id = item.get('relationships', [{}])[0].get('attributes', {}).get('fileName')
                cover_url = f"https://uploads.mangadex.org/covers/{item.get('id')}/{cover_id}.jpg" if cover_id else ""

                results.append({
                    "id": item.get('id'),
                    "title": item.get('attributes', {}).get('title', {}).get('en', 'Unknown'),
                    "cover_url": cover_url,
                    "source": "MangaDex",
                    "type": media_type
                })
            return results
        return []
    except Exception as e:
        print(f"MangaDex error: {e}")
        return []

def search_media(media_type, query):
    """Multi-source search with fallback mechanism"""
    # 1. Try Comick first
    results = fetch_comick(query, media_type)

    # 2. If Comick fails or returns few results, try MangaDex
    if len(results) < 3:
        md_results = fetch_mangadex(query, media_type)
        results.extend(md_results)

    # Remove duplicates by title
    seen = set()
    unique_results = []
    for r in results:
        if r['title'].lower() not in seen:
            unique_results.append(r)
            seen.add(r['title'].lower())

    return json.dumps(unique_results)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(json.dumps({"status": "error", "message": "Missing args"}))
        sys.exit(1)

    media_type = sys.argv[1]
    query = sys.argv[2]

    print(search_media(media_type, query))
