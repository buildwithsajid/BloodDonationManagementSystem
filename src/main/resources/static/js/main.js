document.addEventListener('DOMContentLoaded', function () {
    // 1. Alert close button
    var closeButtons = document.querySelectorAll('.alert-close');
    closeButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            var alertBox = this.closest('.alert');
            if (alertBox) {
                alertBox.style.display = 'none';
            }
        });
    });

    // 2. Auto-dismiss success alert after 5 seconds
    var successAlert = document.querySelector('.alert-success');
    if (successAlert) {
        setTimeout(function () {
            successAlert.style.transition = 'opacity 0.4s ease';
            successAlert.style.opacity = '0';
            setTimeout(function () {
                successAlert.style.display = 'none';
            }, 400);
        }, 5000);
    }

    // 3. Smooth FAQ Accordion
    var accordionHeaders = document.querySelectorAll('.accordion-header');
    accordionHeaders.forEach(function (header) {
        header.addEventListener('click', function () {
            var currentItem = this.closest('.accordion-item');
            var currentContent = currentItem.querySelector('.accordion-content');
            var isAlreadyActive = currentItem.classList.contains('active');

            // Close all other accordion items smoothly
            document.querySelectorAll('.accordion-item').forEach(function (item) {
                item.classList.remove('active');
                var content = item.querySelector('.accordion-content');
                if (content) {
                    content.style.maxHeight = null;
                }
            });

            // Toggle current item
            if (!isAlreadyActive) {
                currentItem.classList.add('active');
                currentContent.style.maxHeight = currentContent.scrollHeight + 'px';
            }
        });
    });

    // Automatically expand the first FAQ item by default
    var firstAccordion = document.querySelector('.accordion-item');
    if (firstAccordion) {
        firstAccordion.classList.add('active');
        var firstContent = firstAccordion.querySelector('.accordion-content');
        if (firstContent) {
            firstContent.style.maxHeight = firstContent.scrollHeight + 'px';
        }
    }
});
