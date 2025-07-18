#!/bin/bash

# Circle Layer Token (CLAYER) Setup Script
# Advanced ERC20 token with dynamic fees and anti-bot protection

echo "🚀 Circle Layer Token (CLAYER) Setup Script"
echo "============================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env already exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file already exists. Backing up to .env.backup${NC}"
    cp .env .env.backup
fi

# Copy template
echo -e "${GREEN}📋 Copying env.template to .env...${NC}"
cp env.template .env

echo ""
echo -e "${GREEN}✅ Environment file created!${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Edit .env file with your API keys:"
echo "   - Get RPC URL from Alchemy, Infura, or Ankr"
echo "   - Get Etherscan API key from https://etherscan.io/apis"
echo "   - Add your private key (keep it secure!)"
echo ""
echo "2. Edit .env file:"
echo "   nano .env          # Edit with nano"
echo "   code .env          # Edit with VS Code"
echo "   vim .env           # Edit with vim"
echo ""
echo "3. Complete development setup:"
echo "   make dev-setup     # Install dependencies, build, and test"
echo ""
echo "4. Or run steps individually:"
echo "   make install       # Install Foundry and dependencies"
echo "   make build         # Build the project"
echo "   make test          # Run comprehensive test suite"
echo ""
echo "5. Test deployment on Sepolia:"
echo "   make deploy-sepolia"
echo ""
echo "6. Deploy to mainnet (when ready):"
echo "   make deploy-mainnet"
echo ""
echo -e "${YELLOW}🔧 Available commands:${NC}"
echo "   make help          # Show all available commands"
echo "   make help-testing  # Show testing help"
echo "   make help-deployment # Show deployment help"
echo ""
echo -e "${YELLOW}🧪 Testing commands:${NC}"
echo "   make test          # Run all tests"
echo "   make test-v        # Verbose output"
echo "   make test-gas      # With gas reporting"
echo "   make test-coverage # Coverage report"
echo "   make test-categories # Run tests by category"
echo ""
echo -e "${YELLOW}📊 Analysis commands:${NC}"
echo "   make analyze       # Contract analysis"
echo "   make gas-snapshot  # Gas usage snapshot"
echo "   make security-check # Security checks"
echo ""
echo -e "${RED}🔒 Security reminders:${NC}"
echo "- Never commit .env to git"
echo "- Use a dedicated deployment wallet"
echo "- Test on Sepolia before mainnet"
echo "- Always run 'make pre-deploy' before mainnet deployment"
echo ""
echo -e "${GREEN}💡 Need help?${NC}"
echo "- Check README.md for detailed instructions"
echo "- Run 'make help' for all available commands"
echo "- Visit https://circlelayer.com for more information"
echo ""
echo -e "${GREEN}🎯 Quick start workflow:${NC}"
echo "1. Edit .env with your keys"
echo "2. make dev-setup"
echo "3. make deploy-sepolia"
echo "4. make deploy-mainnet" 