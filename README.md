# Decentralized Public Utility Bill Processing System

A comprehensive blockchain-based utility management system built on Stacks using Clarity smart contracts.

## Overview

This system provides a decentralized solution for managing public utility services including water, gas, and electricity. It automates meter readings, generates bills, processes payments, manages service disconnections, and offers budget billing options.

## System Architecture

### Core Contracts

1. **Meter Reading Automation** (`meter-reading.clar`)
    - Automated collection of utility usage data
    - Support for water, gas, and electric meters
    - Timestamped readings with validation

2. **Bill Generation** (`bill-generation.clar`)
    - Monthly utility statement creation
    - Rate calculations and due date management
    - Integration with meter readings

3. **Payment Processing** (`payment-processing.clar`)
    - Multi-channel payment support (online, mail, in-person)
    - Payment tracking and confirmation
    - Late fee calculations

4. **Disconnection Management** (`disconnection-management.clar`)
    - Service shutoff management for non-payment
    - Grace period handling
    - Reconnection procedures

5. **Budget Billing** (`budget-billing.clar`)
    - Averaged monthly payment plans
    - Annual reconciliation
    - Customer enrollment management

## Features

- **Automated Meter Readings**: Collect and validate utility usage data
- **Dynamic Bill Generation**: Create accurate monthly statements with proper rate calculations
- **Flexible Payment Options**: Support multiple payment channels with real-time processing
- **Smart Disconnection Logic**: Manage service interruptions with proper notifications
- **Budget Billing Plans**: Offer predictable monthly payments with annual adjustments

## Data Types

### Utility Types
- Water (u1)
- Gas (u2)
- Electric (u3)

### Payment Methods
- Online (u1)
- Mail (u2)
- In-person (u3)

### Service Status
- Active (u1)
- Disconnected (u2)
- Pending (u3)

## Getting Started

### Prerequisites
- Clarinet CLI
- Node.js and npm
- Stacks wallet for testing

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd utility-bill-processing

# Install dependencies
npm install

# Run tests
npm test

# Deploy contracts (testnet)
clarinet deploy --testnet
\`\`\`

### Testing

The system includes comprehensive tests using Vitest:

\`\`\`bash
# Run all tests
npm test

# Run specific test file
npm test meter-reading.test.js
\`\`\`

## Usage Examples

### Recording Meter Readings
\`\`\`clarity
(contract-call? .meter-reading submit-reading u123 u1 u1500 block-height)
\`\`\`

### Generating Bills
\`\`\`clarity
(contract-call? .bill-generation generate-bill u123 u202401)
\`\`\`

### Processing Payments
\`\`\`clarity
(contract-call? .payment-processing process-payment u123 u15000 u1)
\`\`\`

## Security Considerations

- All contracts include proper access controls
- Input validation prevents invalid data entry
- Payment processing includes fraud protection
- Service disconnection requires proper authorization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details
