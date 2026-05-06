import requests
from bs4 import BeautifulSoup
import urllib.parse

def scrape_noon_egypt(query):
    url = f"https://www.noon.com/egypt-en/search/?q={urllib.parse.quote(query)}"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }

    try:
        response = requests.get(url, headers=headers, timeout=20)
        if response.status_code != 200:
            return []

        soup = BeautifulSoup(response.content, "html.parser")
        products = []

        # Noon uses specialized data attributes
        items = soup.find_all("div", {"class": "productContainer"})

        for idx, item in enumerate(items):
            try:
                name_el = item.find("div", {"data-qa": "product-name"})
                price_el = item.find("span", class_="amount")
                img_el = item.find("img")
                link_el = item.find("a")

                if name_el and price_el:
                    products.append({
                        "Sr No": idx + 1,
                        "Product Name": name_el.get_text(strip=True),
                        "Price": float(price_el.get_text(strip=True).replace(",", "")),
                        "Product Image URL": img_el.get("src") if img_el else None,
                        "Product URL": "https://www.noon.com" + link_el.get("href"),
                        "Store Name": "Noon Egypt",
                        "Availability": "In Stock"
                    })
            except:
                continue
        return products
    except Exception as e:
        return []

if __name__ == "__main__":
    print(f"Scraped {len(scrape_noon_egypt('shirt'))} items from Noon.")
