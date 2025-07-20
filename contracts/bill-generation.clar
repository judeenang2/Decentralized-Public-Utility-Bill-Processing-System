;; Bill Generation Contract
;; Creates monthly utility statements and manages due dates

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-INVALID-CUSTOMER (err u201))
(define-constant ERR-BILL-EXISTS (err u202))
(define-constant ERR-BILL-NOT-FOUND (err u203))
(define-constant ERR-INVALID-PERIOD (err u204))

;; Rate constants (per unit)
(define-constant WATER-RATE u50)    ;; 0.50 per unit
(define-constant GAS-RATE u75)      ;; 0.75 per unit
(define-constant ELECTRIC-RATE u120) ;; 1.20 per unit

;; Base service fees
(define-constant WATER-BASE-FEE u1500)    ;; $15.00
(define-constant GAS-BASE-FEE u2000)      ;; $20.00
(define-constant ELECTRIC-BASE-FEE u2500) ;; $25.00

;; Data structures
(define-map customers
  { customer-id: uint }
  {
    name: (string-ascii 50),
    address: (string-ascii 100),
    phone: (string-ascii 15),
    email: (string-ascii 50),
    is-active: bool
  }
)

(define-map bills
  { customer-id: uint, billing-period: uint }
  {
    water-usage: uint,
    gas-usage: uint,
    electric-usage: uint,
    water-charges: uint,
    gas-charges: uint,
    electric-charges: uint,
    total-amount: uint,
    due-date: uint,
    generated-date: uint,
    is-paid: bool
  }
)

(define-map rate-schedules
  { utility-type: uint }
  {
    base-fee: uint,
    rate-per-unit: uint,
    effective-date: uint
  }
)

;; Initialize default rates
(map-set rate-schedules { utility-type: u1 } { base-fee: WATER-BASE-FEE, rate-per-unit: WATER-RATE, effective-date: u0 })
(map-set rate-schedules { utility-type: u2 } { base-fee: GAS-BASE-FEE, rate-per-unit: GAS-RATE, effective-date: u0 })
(map-set rate-schedules { utility-type: u3 } { base-fee: ELECTRIC-BASE-FEE, rate-per-unit: ELECTRIC-RATE, effective-date: u0 })

;; Public functions

;; Register a customer
(define-public (register-customer (customer-id uint) (name (string-ascii 50)) (address (string-ascii 100)) (phone (string-ascii 15)) (email (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? customers { customer-id: customer-id })) ERR-BILL-EXISTS)
    (ok (map-set customers
      { customer-id: customer-id }
      {
        name: name,
        address: address,
        phone: phone,
        email: email,
        is-active: true
      }
    ))
  )
)

;; Generate a bill for a customer
(define-public (generate-bill (customer-id uint) (billing-period uint) (water-usage uint) (gas-usage uint) (electric-usage uint))
  (let (
    (customer-info (unwrap! (map-get? customers { customer-id: customer-id }) ERR-INVALID-CUSTOMER))
    (water-rate-info (unwrap! (map-get? rate-schedules { utility-type: u1 }) ERR-INVALID-PERIOD))
    (gas-rate-info (unwrap! (map-get? rate-schedules { utility-type: u2 }) ERR-INVALID-PERIOD))
    (electric-rate-info (unwrap! (map-get? rate-schedules { utility-type: u3 }) ERR-INVALID-PERIOD))
    (water-charges (+ (get base-fee water-rate-info) (* water-usage (get rate-per-unit water-rate-info))))
    (gas-charges (+ (get base-fee gas-rate-info) (* gas-usage (get rate-per-unit gas-rate-info))))
    (electric-charges (+ (get base-fee electric-rate-info) (* electric-usage (get rate-per-unit electric-rate-info))))
    (total-amount (+ water-charges gas-charges electric-charges))
    (due-date (+ block-height u4320)) ;; 30 days from now (assuming 144 blocks per day)
  )
    (asserts! (get is-active customer-info) ERR-INVALID-CUSTOMER)
    (asserts! (is-none (map-get? bills { customer-id: customer-id, billing-period: billing-period })) ERR-BILL-EXISTS)

    (ok (map-set bills
      { customer-id: customer-id, billing-period: billing-period }
      {
        water-usage: water-usage,
        gas-usage: gas-usage,
        electric-usage: electric-usage,
        water-charges: water-charges,
        gas-charges: gas-charges,
        electric-charges: electric-charges,
        total-amount: total-amount,
        due-date: due-date,
        generated-date: block-height,
        is-paid: false
      }
    ))
  )
)

;; Update rate schedule
(define-public (update-rate-schedule (utility-type uint) (base-fee uint) (rate-per-unit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= utility-type u1) (<= utility-type u3)) ERR-INVALID-PERIOD)
    (ok (map-set rate-schedules
      { utility-type: utility-type }
      {
        base-fee: base-fee,
        rate-per-unit: rate-per-unit,
        effective-date: block-height
      }
    ))
  )
)

;; Mark bill as paid
(define-public (mark-bill-paid (customer-id uint) (billing-period uint))
  (let (
    (bill-info (unwrap! (map-get? bills { customer-id: customer-id, billing-period: billing-period }) ERR-BILL-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set bills
      { customer-id: customer-id, billing-period: billing-period }
      (merge bill-info { is-paid: true })
    ))
  )
)

;; Deactivate customer
(define-public (deactivate-customer (customer-id uint))
  (let (
    (customer-info (unwrap! (map-get? customers { customer-id: customer-id }) ERR-INVALID-CUSTOMER))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set customers
      { customer-id: customer-id }
      (merge customer-info { is-active: false })
    ))
  )
)

;; Read-only functions

;; Get customer information
(define-read-only (get-customer-info (customer-id uint))
  (map-get? customers { customer-id: customer-id })
)

;; Get bill information
(define-read-only (get-bill (customer-id uint) (billing-period uint))
  (map-get? bills { customer-id: customer-id, billing-period: billing-period })
)

;; Get rate schedule
(define-read-only (get-rate-schedule (utility-type uint))
  (map-get? rate-schedules { utility-type: utility-type })
)

;; Check if bill is overdue
(define-read-only (is-bill-overdue (customer-id uint) (billing-period uint))
  (match (map-get? bills { customer-id: customer-id, billing-period: billing-period })
    bill-info (and (not (get is-paid bill-info)) (> block-height (get due-date bill-info)))
    false
  )
)

;; Calculate late fee
(define-read-only (calculate-late-fee (customer-id uint) (billing-period uint))
  (match (map-get? bills { customer-id: customer-id, billing-period: billing-period })
    bill-info (if (and (not (get is-paid bill-info)) (> block-height (get due-date bill-info)))
      (/ (get total-amount bill-info) u20) ;; 5% late fee
      u0
    )
    u0
  )
)
