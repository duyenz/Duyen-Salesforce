# Duyen-Salesforce

## Description
This repository contains Salesforce development projects and customizations. It includes various Salesforce components, configurations, and implementations.

## Project Structure
```
├── force-app/
│   └── main/
│       └── default/
│           ├── classes/        # Apex Classes
│           ├── triggers/       # Apex Triggers
│           ├── layouts/        # Page Layouts
│           ├── objects/        # Custom Objects
│           ├── profiles/       # Profiles
│           └── lwc/           # Lightning Web Components
├── scripts/                    # Deployment and utility scripts
└── config/                    # Configuration files
```

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/duyenz/Duyen-Salesforce.git
   ```
2. Set up your Salesforce DX project:
   ```bash
   sfdx force:project:create -n Duyen-Salesforce
   ```
3. Authorize your Salesforce org:
   ```bash
   sfdx force:auth:web:login -a YourOrgAlias
   ```

## Development
- All development should be done in feature branches
- Follow Salesforce development best practices
- Ensure proper code coverage for Apex classes
- Use SFDX for development and deployment

## Deployment
Instructions for deploying to different environments:

### Sandbox
```bash
sfdx force:source:deploy -p force-app -u YourSandboxAlias
```

### Production
```bash
sfdx force:source:deploy -p force-app -u YourProdAlias
```

## Best Practices
- Write meaningful commit messages
- Keep components small and focused
- Follow Salesforce naming conventions
- Document complex logic and configurations
- Maintain test coverage above 75%

## Contributing
1. Create a new feature branch from main
2. Make your changes
3. Write/update tests as needed
4. Submit a pull request

## Contact
For questions or support, please contact:
- Duyen Tran (duyen@squareup.com)