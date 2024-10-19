;;GreenGrid - Energy Trading Smart Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))

;; Define data variables
(define-data-var energy-price uint u100)

;; Define data maps
(define-map balances principal uint)
(define-map energy-credits principal uint)

;; Public function to buy energy
(define-public (buy-energy (amount uint))
  (let (
    (cost (* amount (var-get energy-price)))
  )
    (if (>= (stx-get-balance tx-sender) cost)
      (begin
        (try! (stx-transfer? cost tx-sender contract-owner))
        (map-set energy-credits tx-sender 
          (+ (default-to u0 (map-get? energy-credits tx-sender)) amount))
        (ok true))
      err-not-enough-balance)))

;; Public function to sell energy
(define-public (sell-energy (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? energy-credits tx-sender)))
  )
    (if (>= current-balance amount)
      (begin
        (map-set energy-credits tx-sender (- current-balance amount))
        (try! (as-contract (stx-transfer? (* amount (var-get energy-price)) contract-owner tx-sender)))
        (ok true))
      err-not-enough-balance)))

;; Admin function to set energy price
(define-public (set-energy-price (new-price uint))
  (if (is-eq tx-sender contract-owner)
    (ok (var-set energy-price new-price))
    err-owner-only))

;; Read-only function to get current energy price
(define-read-only (get-energy-price)
  (ok (var-get energy-price)))

;; Read-only function to get user's energy credit balance
(define-read-only (get-energy-balance (user principal))
  (ok (default-to u0 (map-get? energy-credits user))))