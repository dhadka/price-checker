#!/bin/bash

set -e

check() {
    productPage="$1"
    expectedPrice="$2"

    curl "$productPage" -s \
        -X 'GET' \
        -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
        -H 'Sec-Fetch-Site: same-origin' \
        -H 'Sec-Fetch-Dest: document' \
        -H 'Accept-Language: en-US,en;q=0.9' \
        -H 'Sec-Fetch-Mode: navigate' \
        -H 'Host: www.costco.com' \
        -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15' \
        -H 'Connection: keep-alive' > product.html

    priceTotal=$(cat "product.html" | grep "priceTotal:" | grep -oE "[0-9]+\.[0-9]+")
    priceMin=$(cat "product.html" | grep "priceMin :" | grep -oE "[0-9]+\.[0-9]+" || echo "$priceTotal") # can be 'na'

    echo "Checking $productPage"
    echo "Expected Price: $expectedPrice, Current Price: $priceTotal, Min Price: $priceMin"

    # Negate bc result since it returns 1 if the condition is true, but if needs 0
    if [ ! $(echo "$priceMin < $expectedPrice" | bc) ] || [ ! $(echo "$priceTotal < $expectedPrice" | bc) ]; then
        echo "::error::Product on sale!"
        exit -1
    fi

    echo ""
}

check "https://www.costco.com/intense-951-gravel-bike-1x-sram.product.4000230137.html" "2499.99"
check "https://www.costco.com/intense-951-trail-bike.product.4000136517.html" "2999.99"
