;; GreenGrid Energy Trading Smart Contract with Dynamic Pricing

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-transfer-failed (err u103))
(define-constant err-not-whitelisted (err u104))
(define-constant err-invalid-price (err u105))
(define-constant err-already-whitelisted (err u106))
(define-constant err-not-in-whitelist (err u107))

;; Define data variables
(define-data-var energy-price uint u100)
(define-data-var total-energy-traded uint u0)
(define-data-var price-adjustment-threshold uint u1000)  ;; Threshold for price adjustment
(define-data-var price-adjustment-percentage uint u5)    ;; 5% adjustment

;; Define data maps
(define-map balances principal uint)
(define-map energy-credits principal uint)
(define-map whitelist principal bool)

;; Private function to check if user is whitelisted
(define-private (is-whitelisted (user principal))
  (default-to false (map-get? whitelist user)))

;; Private function to adjust price based on trading volume
(define-private (adjust-price)
  (let (
    (current-price (var-get energy-price))
    (total-traded (var-get total-energy-traded))
    (threshold (var-get price-adjustment-threshold))
    (adjustment-percentage (var-get price-adjustment-percentage))
  )
    (if (>= total-traded threshold)
      (let (
        (price-increase (/ (* current-price adjustment-percentage) u100))
        (new-price (+ current-price price-increase))
      )
        (var-set energy-price new-price)
        (var-set total-energy-traded u0)  ;; Reset the counter
        new-price  ;; Return the new price
      )
      current-price  ;; Return current price if threshold not met
    )
  )
)

;; Public function to buy energy
(define-public (buy-energy (amount uint))
  (let (
    (cost (* amount (var-get energy-price)))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-whitelisted tx-sender) err-not-whitelisted)
    (asserts! (>= (stx-get-balance tx-sender) cost) err-not-enough-balance)
    (try! (stx-transfer? cost tx-sender contract-owner))
    (map-set energy-credits tx-sender 
      (+ (default-to u0 (map-get? energy-credits tx-sender)) amount))
    (var-set total-energy-traded (+ (var-get total-energy-traded) amount))
    (var-set energy-price (adjust-price))  ;; Adjust price after successful transaction
    (ok true)))

;; Public function to sell energy
(define-public (sell-energy (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? energy-credits tx-sender)))
    (payment (* amount (var-get energy-price)))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-whitelisted tx-sender) err-not-whitelisted)
    (asserts! (>= current-balance amount) err-not-enough-balance)
    (map-set energy-credits tx-sender (- current-balance amount))
    (try! (as-contract (stx-transfer? payment contract-owner tx-sender)))
    (var-set total-energy-traded (+ (var-get total-energy-traded) amount))
    (var-set energy-price (adjust-price))  ;; Adjust price after successful transaction
    (ok true)))

;; Admin function to set energy price manually (if needed)
(define-public (set-energy-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-price u0) err-invalid-price)
    (ok (var-set energy-price new-price))))

;; Admin function to set price adjustment parameters
(define-public (set-price-adjustment-params (new-threshold uint) (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-threshold u0) err-invalid-amount)
    (asserts! (and (> new-percentage u0) (<= new-percentage u100)) err-invalid-amount)
    (var-set price-adjustment-threshold new-threshold)
    (var-set price-adjustment-percentage new-percentage)
    (ok true)))

;; Admin function to add user to whitelist
(define-public (add-to-whitelist (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (is-whitelisted user)) err-already-whitelisted)
    (ok (map-set whitelist user true))))

;; Admin function to remove user from whitelist
(define-public (remove-from-whitelist (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-whitelisted user) err-not-in-whitelist)
    (ok (map-delete whitelist user))))

;; Read-only function to get current energy price
(define-read-only (get-energy-price)
  (ok (var-get energy-price)))

;; Read-only function to get user's energy credit balance
(define-read-only (get-energy-balance (user principal))
  (ok (default-to u0 (map-get? energy-credits user))))

;; Read-only function to check if user is whitelisted
(define-read-only (check-whitelist (user principal))
  (ok (is-whitelisted user)))

;; Read-only function to get total energy traded
(define-read-only (get-total-energy-traded)
  (ok (var-get total-energy-traded)))

;; Read-only function to get current price adjustment parameters
(define-read-only (get-price-adjustment-params)
  (ok {
    threshold: (var-get price-adjustment-threshold),
    percentage: (var-get price-adjustment-percentage)
  }))