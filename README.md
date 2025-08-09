# Smart Contract Public Upholstery and Furniture Repair Services

A comprehensive blockchain-based system for managing and regulating upholstery and furniture repair services through smart contracts on the Stacks blockchain.

## System Overview

This system consists of five interconnected smart contracts that manage different aspects of the furniture repair and upholstery industry:

### 1. Upholstery Shop Licensing Contract (`upholstery-licensing.clar`)
- Issues and manages permits for furniture reupholstering and repair services
- Tracks license status, expiration dates, and renewal requirements
- Handles license fees and compliance monitoring

### 2. Antique Restoration Certification Contract (`antique-certification.clar`)
- Manages specialized licenses for antique furniture restoration
- Tracks certification levels and expertise areas
- Maintains records of certified professionals and their qualifications

### 3. Fabric and Material Safety Contract (`material-safety.clar`)
- Ensures upholstery materials meet fire safety and health standards
- Maintains approved material registry
- Tracks safety certifications and compliance reports

### 4. Custom Furniture Maker Oversight Contract (`furniture-oversight.clar`)
- Regulates businesses that build custom furniture and cabinetry
- Manages maker registrations and project tracking
- Handles quality assurance and customer protection

### 5. Furniture Delivery Coordination Contract (`delivery-coordination.clar`)
- Manages delivery and installation services for furniture retailers
- Coordinates scheduling and logistics
- Tracks delivery status and customer satisfaction

## Key Features

- **Decentralized Licensing**: Transparent and immutable licensing system
- **Compliance Tracking**: Automated monitoring of safety standards and regulations
- **Professional Certification**: Verifiable credentials for specialized services
- **Quality Assurance**: Built-in mechanisms for maintaining service standards
- **Coordination Tools**: Streamlined delivery and service coordination

## Contract Architecture

Each contract operates independently while maintaining data consistency through standardized interfaces. The system uses:

- **Principal-based Authentication**: Secure access control for different user types
- **Event Logging**: Comprehensive audit trails for all transactions
- **Fee Management**: Transparent fee structures and payment processing
- **Status Tracking**: Real-time monitoring of licenses, certifications, and services

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for contract deployment

### Installation
\`\`\`bash
git clone <repository-url>
cd furniture-repair-contracts
npm install
clarinet check
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Usage Examples

### Applying for Upholstery License
\`\`\`clarity
(contract-call? .upholstery-licensing apply-for-license "My Upholstery Shop" "123 Main St")
\`\`\`

### Registering Safe Materials
\`\`\`clarity
(contract-call? .material-safety register-material "Fire-Resistant Fabric" "FR-001" u95)
\`\`\`

### Scheduling Delivery
\`\`\`clarity
(contract-call? .delivery-coordination schedule-delivery tx-sender u1234567890 "123 Customer St")
\`\`\`

## Contract Interactions

The contracts are designed to work together seamlessly:
- Licensed shops can register with material safety contract
- Certified restorers can coordinate deliveries
- All services maintain compliance through integrated monitoring

## Security Considerations

- All contracts implement proper access controls
- Critical functions require appropriate permissions
- Fee payments are handled securely
- Data integrity is maintained through validation checks

## Contributing

Please read the PR-DETAILS.md file for information about contributing to this project.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
