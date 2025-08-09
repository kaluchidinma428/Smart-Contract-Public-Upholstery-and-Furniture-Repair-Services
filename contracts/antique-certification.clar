;; Antique Restoration Certification Contract
;; Manages licenses for specialized antique furniture restoration

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-ALREADY-CERTIFIED (err u201))
(define-constant ERR-CERTIFICATION-NOT-FOUND (err u202))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u203))
(define-constant ERR-INVALID-LEVEL (err u204))
(define-constant ERR-INVALID-INPUT (err u205))

;; Certification fees by level
(define-constant BASIC-CERT-FEE u2000000)
(define-constant ADVANCED-CERT-FEE u5000000)
(define-constant MASTER-CERT-FEE u10000000)

;; Certification duration
(define-constant CERT-DURATION u63072000) ;; 2 years in seconds

;; Data Variables
(define-data-var next-cert-id uint u1)
(define-data-var total-certified uint u0)

;; Data Maps
(define-map certifications
  { cert-id: uint }
  {
    restorer-name: (string-ascii 100),
    owner: principal,
    level: (string-ascii 20),
    specialties: (list 5 (string-ascii 50)),
    issue-date: uint,
    expiry-date: uint,
    status: (string-ascii 20),
    projects-completed: uint
  }
)

(define-map restorer-certifications
  { owner: principal }
  { cert-id: uint }
)

(define-map certification-levels
  { level: (string-ascii 20) }
  { fee: uint, requirements: (string-ascii 200) }
)

;; Initialize certification levels
(map-set certification-levels
  { level: "basic" }
  { fee: BASIC-CERT-FEE, requirements: "1 year experience, basic training" }
)

(map-set certification-levels
  { level: "advanced" }
  { fee: ADVANCED-CERT-FEE, requirements: "3 years experience, advanced training" }
)

(map-set certification-levels
  { level: "master" }
  { fee: MASTER-CERT-FEE, requirements: "5+ years experience, master certification" }
)

;; Private Functions
(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (is-valid-level (level (string-ascii 20)))
  (or (or (is-eq level "basic") (is-eq level "advanced")) (is-eq level "master"))
)

(define-private (get-certification-fee (level (string-ascii 20)))
  (match (map-get? certification-levels { level: level })
    level-data (get fee level-data)
    u0
  )
)

;; Public Functions

;; Apply for antique restoration certification
(define-public (apply-for-certification
  (restorer-name (string-ascii 100))
  (level (string-ascii 20))
  (specialties (list 5 (string-ascii 50)))
)
  (let (
    (cert-id (var-get next-cert-id))
    (current-time block-height)
    (expiry-time (+ current-time CERT-DURATION))
    (cert-fee (get-certification-fee level))
  )
    ;; Check if caller already has certification
    (asserts! (is-none (map-get? restorer-certifications { owner: tx-sender })) ERR-ALREADY-CERTIFIED)

    ;; Validate input
    (asserts! (> (len restorer-name) u0) ERR-INVALID-INPUT)
    (asserts! (is-valid-level level) ERR-INVALID-LEVEL)
    (asserts! (> cert-fee u0) ERR-INVALID-LEVEL)

    ;; Process payment
    (try! (stx-transfer? cert-fee tx-sender CONTRACT-OWNER))

    ;; Create certification record
    (map-set certifications
      { cert-id: cert-id }
      {
        restorer-name: restorer-name,
        owner: tx-sender,
        level: level,
        specialties: specialties,
        issue-date: current-time,
        expiry-date: expiry-time,
        status: "active",
        projects-completed: u0
      }
    )

    ;; Map owner to certification
    (map-set restorer-certifications
      { owner: tx-sender }
      { cert-id: cert-id }
    )

    ;; Update contract state
    (var-set next-cert-id (+ cert-id u1))
    (var-set total-certified (+ (var-get total-certified) u1))

    ;; Print event
    (print {
      event: "certification-issued",
      cert-id: cert-id,
      restorer-name: restorer-name,
      level: level,
      owner: tx-sender
    })

    (ok cert-id)
  )
)

;; Update project completion count
(define-public (record-project-completion (cert-id uint))
  (let (
    (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-CERTIFICATION-NOT-FOUND))
  )
    ;; Check ownership
    (asserts! (is-eq (get owner cert-data) tx-sender) ERR-NOT-AUTHORIZED)

    ;; Update project count
    (map-set certifications
      { cert-id: cert-id }
      (merge cert-data {
        projects-completed: (+ (get projects-completed cert-data) u1)
      })
    )

    ;; Print event
    (print {
      event: "project-completed",
      cert-id: cert-id,
      total-projects: (+ (get projects-completed cert-data) u1)
    })

    (ok true)
  )
)

;; Upgrade certification level
(define-public (upgrade-certification (cert-id uint) (new-level (string-ascii 20)))
  (let (
    (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-CERTIFICATION-NOT-FOUND))
    (upgrade-fee (get-certification-fee new-level))
    (current-time block-height)
    (new-expiry (+ current-time CERT-DURATION))
  )
    ;; Check ownership
    (asserts! (is-eq (get owner cert-data) tx-sender) ERR-NOT-AUTHORIZED)

    ;; Validate new level
    (asserts! (is-valid-level new-level) ERR-INVALID-LEVEL)
    (asserts! (> upgrade-fee u0) ERR-INVALID-LEVEL)

    ;; Process upgrade payment
    (try! (stx-transfer? upgrade-fee tx-sender CONTRACT-OWNER))

    ;; Update certification
    (map-set certifications
      { cert-id: cert-id }
      (merge cert-data {
        level: new-level,
        expiry-date: new-expiry
      })
    )

    ;; Print event
    (print {
      event: "certification-upgraded",
      cert-id: cert-id,
      new-level: new-level
    })

    (ok true)
  )
)

;; Revoke certification (admin only)
(define-public (revoke-certification (cert-id uint))
  (let (
    (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-CERTIFICATION-NOT-FOUND))
  )
    ;; Check authorization
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)

    ;; Update certification status
    (map-set certifications
      { cert-id: cert-id }
      (merge cert-data { status: "revoked" })
    )

    ;; Print event
    (print {
      event: "certification-revoked",
      cert-id: cert-id
    })

    (ok true)
  )
)

;; Read-only Functions

;; Get certification information
(define-read-only (get-certification (cert-id uint))
  (map-get? certifications { cert-id: cert-id })
)

;; Get certification by owner
(define-read-only (get-certification-by-owner (owner principal))
  (match (map-get? restorer-certifications { owner: owner })
    owner-data (map-get? certifications { cert-id: (get cert-id owner-data) })
    none
  )
)

;; Get certification level requirements
(define-read-only (get-level-requirements (level (string-ascii 20)))
  (map-get? certification-levels { level: level })
)

;; Get total certified restorers
(define-read-only (get-total-certified)
  (var-get total-certified)
)

;; Check if certification is active
(define-read-only (is-certification-active (cert-id uint))
  (match (map-get? certifications { cert-id: cert-id })
    cert-data (and
      (is-eq (get status cert-data) "active")
      (> (get expiry-date cert-data) block-height)
    )
    false
  )
)
