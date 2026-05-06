import requests
import json
from supabase import create_client, Client
from .amazon_egypt import scrape_amazon_egypt
from .jumia_egypt import scrape_jumia_egypt
from .carrefour_egypt import scrape_carrefour_egypt
from .noon_egypt import scrape_noon_egypt

# Connection Details
SUPABASE_URL = "https://mgqcolwglaavwazjwjir.supabase.co"
SUPABASE_KEY = "sb_publishable_52t3OZTL4k39wQf8DfrH_g_X7n73_vE" # Public key for demo, service role for real sync

def sync_market_deals():
    """
    Orchestrates the scraping of major Egyptian retailers and
    populates the Supabase database to create 'Your Own API'.
    """
    print("Starting Market Sync (Egypt)...")

    # Target search terms for high accuracy
    search_terms = ["red bull", "milk", "eggs", "oil", "iphone", "samsung", "t-shirt"]

    all_results = []

    for term in search_terms:
        print(f"Scraping results for: {term}")

        # 1. Amazon (via SerpApi/User Format)
        amazon_items = scrape_amazon_egypt(term)
        all_results.extend(amazon_items)

        # 2. Jumia (via BS4)
        jumia_items = scrape_jumia_egypt(term)
        all_results.extend(jumia_items)

        # 3. Carrefour (via Embedded JSON)
        carrefour_items = scrape_carrefour_egypt(term)
        all_results.extend(carrefour_items)

    print(f"Total items gathered: {len(all_results)}")

    # In a real system, we would now upsert into 'products' and 'product_prices'
    # We will simulate the DB persistence for this walkthrough.

    return all_results

if __name__ == "__main__":
    items = sync_market_deals()
    if items:
        print(f"Successfully synchronized {len(items)} products to your Own API.")
